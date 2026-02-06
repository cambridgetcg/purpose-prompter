/**
 * Directory Knowledge Resolver
 * Handles inheritance resolution and knowledge merging
 */

import * as path from 'path';
import type {
  DirectoryKnowledge,
  ResolvedKnowledge,
  AncestryEntry,
  PatternKnowledge,
  ContextKnowledge,
  GotchaKnowledge,
  DomainKnowledge,
  OverrideKnowledge,
  DirectoryQueryOptions,
  KnowledgeTreeNode,
  KnowledgeType,
} from './types';
import { LocalDirectoryStore, findProjectRoot, calculateDepth, getLocalStore } from './local-store';

// ============================================================================
// Resolver Class
// ============================================================================

export class DirectoryKnowledgeResolver {
  private store: LocalDirectoryStore;

  constructor(store?: LocalDirectoryStore) {
    this.store = store || getLocalStore();
  }

  // ==========================================================================
  // Main Resolution
  // ==========================================================================

  /**
   * Resolve effective knowledge for a directory
   * Merges knowledge from global → project → parent dirs → target
   */
  async resolve(options: DirectoryQueryOptions): Promise<ResolvedKnowledge> {
    const targetPath = path.resolve(options.path);
    const projectRoot = options.projectRoot || findProjectRoot(targetPath) || targetPath;

    const result: ResolvedKnowledge = {
      targetPath,
      projectRoot,
      patterns: new Map(),
      contexts: [],
      gotchas: [],
      domains: [],
      overrides: new Map(),
      ancestry: [],
    };

    // 1. Start with global knowledge (if enabled)
    if (options.includeGlobal !== false) {
      const global = this.store.loadGlobal();
      if (global) {
        this.mergeKnowledge(result, global, 'global', 0, options);
      }
    }

    // 2. Build path segments from project root to target
    const relativePath = path.relative(projectRoot, targetPath);
    const segments = relativePath ? relativePath.split(path.sep) : [];

    // 3. Walk down the tree, accumulating and overriding
    let currentPath = projectRoot;
    const maxDepth = options.maxDepth ?? 100;

    for (let depth = 1; depth <= segments.length + 1 && depth <= maxDepth; depth++) {
      if (this.store.hasKnowledge(currentPath)) {
        try {
          const dirKnowledge = this.store.load(currentPath);
          const scope = depth === 1 ? 'project' : 'directory';
          this.mergeKnowledge(result, dirKnowledge, scope, depth, options);
        } catch {
          // Skip directories with invalid knowledge
        }
      }

      // Move to next segment
      if (depth <= segments.length) {
        currentPath = path.join(currentPath, segments[depth - 1]);
      }
    }

    return result;
  }

  /**
   * Get the ancestry chain for a directory
   */
  async getAncestry(targetPath: string): Promise<AncestryEntry[]> {
    const resolvedPath = path.resolve(targetPath);
    const projectRoot = findProjectRoot(resolvedPath) || resolvedPath;
    const ancestry: AncestryEntry[] = [];

    // Check global
    const global = this.store.loadGlobal();
    if (global) {
      ancestry.push(this.createAncestryEntry(global, 'global', 0));
    }

    // Walk from project root to target
    const relativePath = path.relative(projectRoot, resolvedPath);
    const segments = relativePath ? relativePath.split(path.sep) : [];

    let currentPath = projectRoot;
    for (let depth = 1; depth <= segments.length + 1; depth++) {
      if (this.store.hasKnowledge(currentPath)) {
        try {
          const dirKnowledge = this.store.load(currentPath);
          const scope = depth === 1 ? 'project' : 'directory';
          ancestry.push(this.createAncestryEntry(dirKnowledge, scope, depth));
        } catch {
          // Skip invalid directories
        }
      }

      if (depth <= segments.length) {
        currentPath = path.join(currentPath, segments[depth - 1]);
      }
    }

    return ancestry;
  }

  // ==========================================================================
  // Tree Building
  // ==========================================================================

  /**
   * Build a knowledge tree for visualization
   */
  async buildTree(rootPath: string, maxDepth?: number): Promise<KnowledgeTreeNode> {
    const resolvedRoot = path.resolve(rootPath);
    const depth = maxDepth ?? 5;

    const buildNode = (nodePath: string, currentDepth: number): KnowledgeTreeNode => {
      const hasKnowledge = this.store.hasKnowledge(nodePath);
      let knowledgeSummary: KnowledgeTreeNode['knowledge'];

      if (hasKnowledge) {
        try {
          const knowledge = this.store.load(nodePath);
          knowledgeSummary = {
            patternCount: knowledge.patterns.size,
            contextCount: knowledge.contexts.length,
            gotchaCount: knowledge.gotchas.length,
            overrideCount: knowledge.overrides.size,
            domainCount: knowledge.domains.length,
            patternNames: Array.from(knowledge.patterns.keys()),
            gotchaNames: knowledge.gotchas.map(g => g.name),
          };
        } catch {
          // Invalid knowledge, skip summary
        }
      }

      const node: KnowledgeTreeNode = {
        name: path.basename(nodePath) || nodePath,
        path: nodePath,
        hasKnowledge,
        knowledge: knowledgeSummary,
        children: [],
        depth: currentDepth,
      };

      // Build children if not at max depth
      if (currentDepth < depth) {
        node.children = this.getChildNodes(nodePath, currentDepth + 1);
      }

      return node;
    };

    return buildNode(resolvedRoot, 0);
  }

  /**
   * Get child nodes for a directory
   */
  private getChildNodes(parentPath: string, depth: number): KnowledgeTreeNode[] {
    const children: KnowledgeTreeNode[] = [];
    const config = this.store.getConfig();

    try {
      const fs = require('fs');
      const entries = fs.readdirSync(parentPath, { withFileTypes: true });

      for (const entry of entries) {
        // Skip hidden directories and excluded patterns
        if (entry.name.startsWith('.') || config.excludePatterns.includes(entry.name)) {
          continue;
        }

        if (entry.isDirectory()) {
          const childPath = path.join(parentPath, entry.name);
          const hasKnowledge = this.store.hasKnowledge(childPath);
          let knowledgeSummary: KnowledgeTreeNode['knowledge'];

          if (hasKnowledge) {
            try {
              const knowledge = this.store.load(childPath);
              knowledgeSummary = {
                patternCount: knowledge.patterns.size,
                contextCount: knowledge.contexts.length,
                gotchaCount: knowledge.gotchas.length,
                overrideCount: knowledge.overrides.size,
                domainCount: knowledge.domains.length,
                patternNames: Array.from(knowledge.patterns.keys()),
                gotchaNames: knowledge.gotchas.map(g => g.name),
              };
            } catch {
              // Skip invalid knowledge
            }
          }

          // Only include if has knowledge or has children with knowledge
          const childDirs = this.getChildNodes(childPath, depth + 1);
          const hasKnowledgeInTree = hasKnowledge || childDirs.length > 0;

          if (hasKnowledgeInTree) {
            children.push({
              name: entry.name,
              path: childPath,
              hasKnowledge,
              knowledge: knowledgeSummary,
              children: childDirs,
              depth,
            });
          }
        }
      }
    } catch {
      // Can't read directory
    }

    return children;
  }

  // ==========================================================================
  // Formatting
  // ==========================================================================

  /**
   * Format resolved knowledge as markdown
   */
  formatAsMarkdown(resolved: ResolvedKnowledge): string {
    const lines: string[] = [];

    lines.push(`# Effective Knowledge for ${resolved.targetPath}`);
    lines.push('');

    // Ancestry
    lines.push('## Inheritance Chain');
    lines.push('');
    for (const entry of resolved.ancestry) {
      const indent = '  '.repeat(entry.depth);
      lines.push(`${indent}- **[${entry.scope.toUpperCase()}]** ${entry.path}`);
      lines.push(`${indent}  - Patterns: ${entry.patternCount}, Contexts: ${entry.contextCount}, Gotchas: ${entry.gotchaCount}`);
      if (entry.overriddenItems.length > 0) {
        lines.push(`${indent}  - Overrides: ${entry.overriddenItems.join(', ')}`);
      }
    }
    lines.push('');

    // Patterns
    if (resolved.patterns.size > 0) {
      lines.push('## Patterns');
      lines.push('');
      for (const [name, pattern] of resolved.patterns) {
        lines.push(`### ${name}`);
        if (pattern.ppDimension) {
          lines.push(`*PP Dimension: ${pattern.ppDimension}*`);
        }
        lines.push('');
        lines.push(pattern.content);
        lines.push('');
      }
    }

    // Contexts
    if (resolved.contexts.length > 0) {
      lines.push('## Context');
      lines.push('');
      for (const context of resolved.contexts) {
        lines.push(`### ${context.name}`);
        lines.push('');
        lines.push(context.content);
        lines.push('');
      }
    }

    // Gotchas
    if (resolved.gotchas.length > 0) {
      lines.push('## Gotchas');
      lines.push('');
      for (const gotcha of resolved.gotchas) {
        const severity = gotcha.severity ? ` [${gotcha.severity.toUpperCase()}]` : '';
        lines.push(`### ${gotcha.name}${severity}`);
        if (gotcha.ppDimension) {
          lines.push(`*PP Dimension: ${gotcha.ppDimension}*`);
        }
        lines.push('');
        lines.push(gotcha.content);
        lines.push('');
      }
    }

    // Domains
    if (resolved.domains.length > 0) {
      lines.push('## Domain Knowledge');
      lines.push('');
      for (const domain of resolved.domains) {
        lines.push(`### ${domain.name}`);
        lines.push('');
        lines.push(domain.content);
        lines.push('');
      }
    }

    return lines.join('\n');
  }

  /**
   * Format as JSON
   */
  formatAsJson(resolved: ResolvedKnowledge): string {
    const data = {
      targetPath: resolved.targetPath,
      projectRoot: resolved.projectRoot,
      ancestry: resolved.ancestry,
      patterns: Object.fromEntries(resolved.patterns),
      contexts: resolved.contexts,
      gotchas: resolved.gotchas,
      domains: resolved.domains,
      overrides: Object.fromEntries(resolved.overrides),
    };
    return JSON.stringify(data, null, 2);
  }

  /**
   * Format knowledge tree as ASCII art
   */
  formatTree(node: KnowledgeTreeNode, prefix: string = '', isLast: boolean = true): string {
    const lines: string[] = [];

    // Node line
    const connector = isLast ? '└── ' : '├── ';
    const knowledgeInfo = node.hasKnowledge
      ? ` (.gua: ${node.knowledge?.patternCount || 0}p, ${node.knowledge?.gotchaCount || 0}g)`
      : '';
    lines.push(`${prefix}${connector}${node.name}/${knowledgeInfo}`);

    // Children
    const childPrefix = prefix + (isLast ? '    ' : '│   ');
    for (let i = 0; i < node.children.length; i++) {
      const child = node.children[i];
      const childIsLast = i === node.children.length - 1;
      lines.push(this.formatTree(child, childPrefix, childIsLast));
    }

    return lines.join('\n');
  }

  // ==========================================================================
  // Private Helpers
  // ==========================================================================

  /**
   * Merge knowledge from a directory into the result
   */
  private mergeKnowledge(
    result: ResolvedKnowledge,
    knowledge: DirectoryKnowledge,
    scope: 'global' | 'project' | 'directory',
    depth: number,
    options: DirectoryQueryOptions
  ): void {
    const overriddenItems: string[] = [];

    // Apply type filter
    const typeFilter = options.types;
    const ppFilter = options.ppDimension;
    const tagFilter = options.tags;

    const shouldInclude = (type: KnowledgeType, ppDim?: string, tags?: string[]): boolean => {
      if (typeFilter && !typeFilter.includes(type)) return false;
      if (ppFilter && ppDim !== ppFilter) return false;
      if (tagFilter && tagFilter.length > 0) {
        if (!tags || !tagFilter.some(t => tags.includes(t))) return false;
      }
      return true;
    };

    // Merge patterns (with override detection)
    for (const [name, pattern] of knowledge.patterns) {
      if (!shouldInclude('pattern', pattern.ppDimension, pattern.tags)) continue;

      if (result.patterns.has(name)) {
        overriddenItems.push(name);
      }
      result.patterns.set(name, pattern);
    }

    // Apply explicit overrides
    for (const [name, override] of knowledge.overrides) {
      if (!shouldInclude('override', override.ppDimension, override.tags)) continue;

      // Find what this overrides
      const targetName = override.overrides;
      if (result.patterns.has(targetName)) {
        overriddenItems.push(targetName);
        // Create a pattern from the override content
        const overrideAsPattern: PatternKnowledge = {
          id: override.id,
          name: targetName,
          type: 'pattern',
          content: override.content,
          ppDimension: override.ppDimension,
          tags: override.tags,
          createdAt: override.createdAt,
          updatedAt: override.updatedAt,
        };
        result.patterns.set(targetName, overrideAsPattern);
      }
      result.overrides.set(name, override);
    }

    // Accumulate contexts
    for (const context of knowledge.contexts) {
      if (!shouldInclude('context', context.ppDimension, context.tags)) continue;
      result.contexts.push(context);
    }

    // Accumulate gotchas
    for (const gotcha of knowledge.gotchas) {
      if (!shouldInclude('gotcha', gotcha.ppDimension, gotcha.tags)) continue;
      result.gotchas.push(gotcha);
    }

    // Accumulate domains
    for (const domain of knowledge.domains) {
      if (!shouldInclude('domain', domain.ppDimension, domain.tags)) continue;
      result.domains.push(domain);
    }

    // Add ancestry entry
    result.ancestry.push({
      path: knowledge.path,
      scope,
      depth,
      patternCount: knowledge.patterns.size,
      contextCount: knowledge.contexts.length,
      gotchaCount: knowledge.gotchas.length,
      overriddenItems,
    });
  }

  /**
   * Create an ancestry entry from directory knowledge
   */
  private createAncestryEntry(
    knowledge: DirectoryKnowledge,
    scope: 'global' | 'project' | 'directory',
    depth: number
  ): AncestryEntry {
    return {
      path: knowledge.path,
      scope,
      depth,
      patternCount: knowledge.patterns.size,
      contextCount: knowledge.contexts.length,
      gotchaCount: knowledge.gotchas.length,
      overriddenItems: Array.from(knowledge.overrides.keys()),
    };
  }
}

// ============================================================================
// Factory
// ============================================================================

export function createResolver(store?: LocalDirectoryStore): DirectoryKnowledgeResolver {
  return new DirectoryKnowledgeResolver(store);
}

// ============================================================================
// Convenience Functions
// ============================================================================

/**
 * Resolve knowledge for a path (convenience function)
 */
export async function resolveKnowledge(targetPath: string, options?: Partial<DirectoryQueryOptions>): Promise<ResolvedKnowledge> {
  const resolver = createResolver();
  return resolver.resolve({ path: targetPath, ...options });
}

/**
 * Get ancestry for a path (convenience function)
 */
export async function getAncestry(targetPath: string): Promise<AncestryEntry[]> {
  const resolver = createResolver();
  return resolver.getAncestry(targetPath);
}

/**
 * Build knowledge tree (convenience function)
 */
export async function buildKnowledgeTree(rootPath: string, maxDepth?: number): Promise<KnowledgeTreeNode> {
  const resolver = createResolver();
  return resolver.buildTree(rootPath, maxDepth);
}

/**
 * Get effective context as formatted markdown
 */
export async function getEffectiveContext(targetPath: string): Promise<string> {
  const resolver = createResolver();
  const resolved = await resolver.resolve({ path: targetPath });
  return resolver.formatAsMarkdown(resolved);
}
