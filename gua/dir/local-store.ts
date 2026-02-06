/**
 * Local Directory Knowledge Store
 * Handles local .gua/ folder operations for directory knowledge
 */

import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';
import type {
  DirectoryKnowledge,
  DirectoryManifest,
  KnowledgeScope,
  KnowledgeType,
  KnowledgeItem,
  PatternKnowledge,
  ContextKnowledge,
  GotchaKnowledge,
  OverrideKnowledge,
  DomainKnowledge,
  AddKnowledgeOptions,
  ProjectRegistryEntry,
  DirectoryKnowledgeConfig,
  AnyKnowledgeItem,
  PPDimension,
} from './types';

// ============================================================================
// Constants
// ============================================================================

const GUA_DIR = '.gua';
const GLOBAL_GUA_DIR = path.join(process.env.HOME || '~', '.gua');
const MANIFEST_FILE = 'manifest.json';
const CONFIG_FILE = 'config.json';
const REGISTRY_FILE = 'projects/registry.json';

const DEFAULT_CONFIG: DirectoryKnowledgeConfig = {
  version: '1.0.0',
  defaultCascade: true,
  autoSync: false,
  syncIntervalMinutes: 60,
  excludePatterns: ['node_modules', '.git', 'dist', 'build', 'coverage'],
  maxDepth: 10,
};

// ============================================================================
// Utility Functions
// ============================================================================

/**
 * Generate a hash for a path
 */
export function hashPath(inputPath: string): string {
  return crypto.createHash('md5').update(inputPath).digest('hex').substring(0, 12);
}

/**
 * Generate a unique ID for a knowledge item
 */
export function generateId(type: KnowledgeType, name: string): string {
  const timestamp = Date.now().toString(36);
  const hash = hashPath(`${type}#${name}#${timestamp}`).substring(0, 6);
  return `${type}-${hash}`;
}

/**
 * Find project root by looking for common markers
 */
export function findProjectRoot(startPath: string): string | null {
  const markers = ['.git', 'package.json', 'Cargo.toml', 'go.mod', 'pyproject.toml', '.gua'];
  let current = path.resolve(startPath);
  const root = path.parse(current).root;

  while (current !== root) {
    for (const marker of markers) {
      if (fs.existsSync(path.join(current, marker))) {
        return current;
      }
    }
    current = path.dirname(current);
  }

  return null;
}

/**
 * Calculate depth from project root
 */
export function calculateDepth(targetPath: string, projectRoot: string): number {
  const relative = path.relative(projectRoot, targetPath);
  if (!relative) return 1; // Project root is depth 1
  return relative.split(path.sep).length + 1;
}

/**
 * Ensure directory exists
 */
function ensureDir(dirPath: string): void {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

/**
 * Read JSON file safely
 */
function readJson<T>(filePath: string): T | null {
  try {
    if (!fs.existsSync(filePath)) return null;
    const content = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(content) as T;
  } catch {
    return null;
  }
}

/**
 * Write JSON file
 */
function writeJson(filePath: string, data: unknown): void {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf-8');
}

/**
 * Read markdown file
 */
function readMarkdown(filePath: string): string | null {
  try {
    if (!fs.existsSync(filePath)) return null;
    return fs.readFileSync(filePath, 'utf-8');
  } catch {
    return null;
  }
}

/**
 * Write markdown file
 */
function writeMarkdown(filePath: string, content: string): void {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, content, 'utf-8');
}

// ============================================================================
// Local Store Class
// ============================================================================

export class LocalDirectoryStore {
  private globalPath: string;
  private config: DirectoryKnowledgeConfig;

  constructor(globalPath?: string) {
    this.globalPath = globalPath || GLOBAL_GUA_DIR;
    this.config = this.loadConfig();
  }

  // ==========================================================================
  // Configuration
  // ==========================================================================

  private loadConfig(): DirectoryKnowledgeConfig {
    const configPath = path.join(this.globalPath, CONFIG_FILE);
    const config = readJson<DirectoryKnowledgeConfig>(configPath);
    return config ? { ...DEFAULT_CONFIG, ...config } : DEFAULT_CONFIG;
  }

  saveConfig(config: Partial<DirectoryKnowledgeConfig>): void {
    this.config = { ...this.config, ...config };
    const configPath = path.join(this.globalPath, CONFIG_FILE);
    writeJson(configPath, this.config);
  }

  getConfig(): DirectoryKnowledgeConfig {
    return { ...this.config };
  }

  // ==========================================================================
  // Directory Operations
  // ==========================================================================

  /**
   * Get the .gua path for a directory
   */
  getGuaPath(dirPath: string): string {
    return path.join(dirPath, GUA_DIR);
  }

  /**
   * Check if directory has .gua/
   */
  hasKnowledge(dirPath: string): boolean {
    return fs.existsSync(this.getGuaPath(dirPath));
  }

  /**
   * Initialize .gua/ in a directory
   */
  init(dirPath: string, options?: { template?: string; scope?: KnowledgeScope }): void {
    const guaPath = this.getGuaPath(dirPath);

    if (this.hasKnowledge(dirPath)) {
      throw new Error(`Directory already initialized: ${dirPath}`);
    }

    // Determine scope
    const projectRoot = findProjectRoot(dirPath);
    let scope: KnowledgeScope;
    if (dirPath === this.globalPath) {
      scope = 'global';
    } else if (!projectRoot || dirPath === projectRoot) {
      scope = 'project';
    } else {
      scope = 'directory';
    }

    if (options?.scope) {
      scope = options.scope;
    }

    // Create directory structure
    ensureDir(guaPath);
    ensureDir(path.join(guaPath, 'patterns'));
    ensureDir(path.join(guaPath, 'contexts'));
    ensureDir(path.join(guaPath, 'gotchas'));
    ensureDir(path.join(guaPath, 'domains'));

    // Create manifest
    const manifest: DirectoryManifest = {
      version: '1.0.0',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      path: dirPath,
      scope,
      counts: {
        patterns: 0,
        contexts: 0,
        gotchas: 0,
        overrides: 0,
        domains: 0,
      },
    };

    writeJson(path.join(guaPath, MANIFEST_FILE), manifest);

    // Create initial context.md
    const contextTemplate = `# ${scope === 'global' ? 'Global' : scope === 'project' ? 'Project' : 'Directory'} Context

## Overview

<!-- Describe this ${scope === 'directory' ? 'directory' : scope} -->

## Key Concepts

-

## Important Notes

-
`;

    writeMarkdown(path.join(guaPath, 'context.md'), contextTemplate);

    // Register project if this is a project root
    if (scope === 'project') {
      this.registerProject(dirPath);
    }
  }

  /**
   * Initialize global knowledge structure
   */
  initGlobal(): void {
    const globalKnowledgePath = path.join(this.globalPath, 'global');

    if (fs.existsSync(globalKnowledgePath)) {
      return; // Already initialized
    }

    ensureDir(globalKnowledgePath);
    ensureDir(path.join(globalKnowledgePath, 'patterns'));
    ensureDir(path.join(globalKnowledgePath, 'gotchas'));
    ensureDir(path.join(globalKnowledgePath, 'domains'));

    // Create manifest
    const manifest: DirectoryManifest = {
      version: '1.0.0',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      path: globalKnowledgePath,
      scope: 'global',
      counts: {
        patterns: 0,
        contexts: 0,
        gotchas: 0,
        overrides: 0,
        domains: 0,
      },
    };

    writeJson(path.join(globalKnowledgePath, MANIFEST_FILE), manifest);

    // Create global context
    writeMarkdown(path.join(globalKnowledgePath, 'context.md'), `# Global Knowledge Context

## General Patterns

This contains patterns that apply across all projects.

## Usage

Global knowledge cascades down to all projects and directories unless overridden locally.
`);
  }

  // ==========================================================================
  // Knowledge CRUD
  // ==========================================================================

  /**
   * Add knowledge to a directory
   */
  add(options: AddKnowledgeOptions): KnowledgeItem {
    const dirPath = options.path || process.cwd();
    const guaPath = this.getGuaPath(dirPath);

    if (!this.hasKnowledge(dirPath)) {
      throw new Error(`Directory not initialized. Run 'gua dir init' first: ${dirPath}`);
    }

    const id = generateId(options.type, options.name);
    const now = new Date();
    const item: AnyKnowledgeItem = {
      id,
      name: options.name,
      type: options.type,
      content: options.content,
      ppDimension: options.ppDimension,
      tags: options.tags,
      createdAt: now,
      updatedAt: now,
    } as AnyKnowledgeItem;

    // Type-specific handling
    switch (options.type) {
      case 'pattern': {
        const patternPath = path.join(guaPath, 'patterns', `${options.name}.md`);
        const patternMeta = path.join(guaPath, 'patterns', `${options.name}.json`);
        writeMarkdown(patternPath, options.content);
        writeJson(patternMeta, {
          id,
          name: options.name,
          type: 'pattern',
          ppDimension: options.ppDimension,
          tags: options.tags,
          cascade: options.cascade ?? this.config.defaultCascade,
          createdAt: now.toISOString(),
          updatedAt: now.toISOString(),
        });
        break;
      }
      case 'context': {
        const contextPath = path.join(guaPath, 'contexts', `${options.name}.md`);
        const contextMeta = path.join(guaPath, 'contexts', `${options.name}.json`);
        writeMarkdown(contextPath, options.content);
        writeJson(contextMeta, {
          id,
          name: options.name,
          type: 'context',
          describes: 'general',
          ppDimension: options.ppDimension,
          tags: options.tags,
          createdAt: now.toISOString(),
          updatedAt: now.toISOString(),
        });
        break;
      }
      case 'gotcha': {
        const gotchaPath = path.join(guaPath, 'gotchas', `${options.name}.md`);
        const gotchaMeta = path.join(guaPath, 'gotchas', `${options.name}.json`);
        writeMarkdown(gotchaPath, options.content);
        writeJson(gotchaMeta, {
          id,
          name: options.name,
          type: 'gotcha',
          ppDimension: options.ppDimension,
          tags: options.tags,
          severity: 'medium',
          createdAt: now.toISOString(),
          updatedAt: now.toISOString(),
        });
        break;
      }
      case 'override': {
        if (!options.overrides) {
          throw new Error('Override requires specifying which item to override');
        }
        const overridePath = path.join(guaPath, 'overrides', `${options.name}.md`);
        const overrideMeta = path.join(guaPath, 'overrides', `${options.name}.json`);
        ensureDir(path.join(guaPath, 'overrides'));
        writeMarkdown(overridePath, options.content);
        writeJson(overrideMeta, {
          id,
          name: options.name,
          type: 'override',
          overrides: options.overrides,
          ppDimension: options.ppDimension,
          tags: options.tags,
          createdAt: now.toISOString(),
          updatedAt: now.toISOString(),
        });
        break;
      }
      case 'domain': {
        const domainPath = path.join(guaPath, 'domains', `${options.name}.md`);
        const domainMeta = path.join(guaPath, 'domains', `${options.name}.json`);
        writeMarkdown(domainPath, options.content);
        writeJson(domainMeta, {
          id,
          name: options.name,
          type: 'domain',
          domain: options.name,
          ppDimension: options.ppDimension,
          tags: options.tags,
          createdAt: now.toISOString(),
          updatedAt: now.toISOString(),
        });
        break;
      }
    }

    // Update manifest
    this.updateManifestCounts(dirPath);

    return item;
  }

  /**
   * Remove knowledge from a directory
   */
  remove(dirPath: string, type: KnowledgeType, name: string): boolean {
    const guaPath = this.getGuaPath(dirPath);

    if (!this.hasKnowledge(dirPath)) {
      return false;
    }

    const subdir = type === 'override' ? 'overrides' : `${type}s`;
    const mdPath = path.join(guaPath, subdir, `${name}.md`);
    const jsonPath = path.join(guaPath, subdir, `${name}.json`);

    let removed = false;
    if (fs.existsSync(mdPath)) {
      fs.unlinkSync(mdPath);
      removed = true;
    }
    if (fs.existsSync(jsonPath)) {
      fs.unlinkSync(jsonPath);
      removed = true;
    }

    if (removed) {
      this.updateManifestCounts(dirPath);
    }

    return removed;
  }

  /**
   * Load all knowledge from a directory
   */
  load(dirPath: string): DirectoryKnowledge {
    const guaPath = this.getGuaPath(dirPath);

    if (!this.hasKnowledge(dirPath)) {
      throw new Error(`No knowledge found in: ${dirPath}`);
    }

    const manifest = readJson<DirectoryManifest>(path.join(guaPath, MANIFEST_FILE));
    if (!manifest) {
      throw new Error(`Invalid manifest in: ${dirPath}`);
    }

    const projectRoot = findProjectRoot(dirPath);
    const relativePath = projectRoot ? path.relative(projectRoot, dirPath) : '';
    const depth = projectRoot ? calculateDepth(dirPath, projectRoot) : 1;

    const knowledge: DirectoryKnowledge = {
      path: dirPath,
      relativePath,
      scope: manifest.scope,
      depth,
      projectPath: projectRoot || undefined,
      patterns: new Map(),
      contexts: [],
      gotchas: [],
      overrides: new Map(),
      domains: [],
      lastSynced: manifest.lastSync ? new Date(manifest.lastSync.timestamp) : undefined,
    };

    // Load patterns
    const patternsDir = path.join(guaPath, 'patterns');
    if (fs.existsSync(patternsDir)) {
      for (const file of fs.readdirSync(patternsDir)) {
        if (file.endsWith('.md')) {
          const name = path.basename(file, '.md');
          const content = readMarkdown(path.join(patternsDir, file));
          const meta = readJson<Record<string, unknown>>(path.join(patternsDir, `${name}.json`));
          if (content) {
            const pattern: PatternKnowledge = {
              id: (meta?.id as string) || generateId('pattern', name),
              name,
              type: 'pattern',
              content,
              ppDimension: meta?.ppDimension as PPDimension | undefined,
              tags: meta?.tags as string[] | undefined,
              createdAt: meta?.createdAt ? new Date(meta.createdAt as string) : new Date(),
              updatedAt: meta?.updatedAt ? new Date(meta.updatedAt as string) : new Date(),
            };
            knowledge.patterns.set(name, pattern);
          }
        }
      }
    }

    // Load contexts
    const contextsDir = path.join(guaPath, 'contexts');
    if (fs.existsSync(contextsDir)) {
      for (const file of fs.readdirSync(contextsDir)) {
        if (file.endsWith('.md')) {
          const name = path.basename(file, '.md');
          const content = readMarkdown(path.join(contextsDir, file));
          const meta = readJson<Record<string, unknown>>(path.join(contextsDir, `${name}.json`));
          if (content) {
            const context: ContextKnowledge = {
              id: (meta?.id as string) || generateId('context', name),
              name,
              type: 'context',
              content,
              describes: (meta?.describes as ContextKnowledge['describes']) || 'general',
              ppDimension: meta?.ppDimension as PPDimension | undefined,
              tags: meta?.tags as string[] | undefined,
              createdAt: meta?.createdAt ? new Date(meta.createdAt as string) : new Date(),
              updatedAt: meta?.updatedAt ? new Date(meta.updatedAt as string) : new Date(),
            };
            knowledge.contexts.push(context);
          }
        }
      }
    }

    // Also check for root context.md
    const rootContext = readMarkdown(path.join(guaPath, 'context.md'));
    if (rootContext) {
      knowledge.contexts.unshift({
        id: generateId('context', 'main'),
        name: 'main',
        type: 'context',
        content: rootContext,
        describes: 'general',
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    }

    // Load gotchas
    const gotchasDir = path.join(guaPath, 'gotchas');
    if (fs.existsSync(gotchasDir)) {
      for (const file of fs.readdirSync(gotchasDir)) {
        if (file.endsWith('.md')) {
          const name = path.basename(file, '.md');
          const content = readMarkdown(path.join(gotchasDir, file));
          const meta = readJson<Record<string, unknown>>(path.join(gotchasDir, `${name}.json`));
          if (content) {
            const gotcha: GotchaKnowledge = {
              id: (meta?.id as string) || generateId('gotcha', name),
              name,
              type: 'gotcha',
              content,
              severity: (meta?.severity as GotchaKnowledge['severity']) || 'medium',
              ppDimension: meta?.ppDimension as PPDimension | undefined,
              tags: meta?.tags as string[] | undefined,
              createdAt: meta?.createdAt ? new Date(meta.createdAt as string) : new Date(),
              updatedAt: meta?.updatedAt ? new Date(meta.updatedAt as string) : new Date(),
            };
            knowledge.gotchas.push(gotcha);
          }
        }
      }
    }

    // Load overrides
    const overridesDir = path.join(guaPath, 'overrides');
    if (fs.existsSync(overridesDir)) {
      for (const file of fs.readdirSync(overridesDir)) {
        if (file.endsWith('.md')) {
          const name = path.basename(file, '.md');
          const content = readMarkdown(path.join(overridesDir, file));
          const meta = readJson<Record<string, unknown>>(path.join(overridesDir, `${name}.json`));
          if (content && meta?.overrides) {
            const override: OverrideKnowledge = {
              id: (meta?.id as string) || generateId('override', name),
              name,
              type: 'override',
              content,
              overrides: meta.overrides as string,
              reason: meta?.reason as string | undefined,
              ppDimension: meta?.ppDimension as PPDimension | undefined,
              tags: meta?.tags as string[] | undefined,
              createdAt: meta?.createdAt ? new Date(meta.createdAt as string) : new Date(),
              updatedAt: meta?.updatedAt ? new Date(meta.updatedAt as string) : new Date(),
            };
            knowledge.overrides.set(name, override);
          }
        }
      }
    }

    // Load domains
    const domainsDir = path.join(guaPath, 'domains');
    if (fs.existsSync(domainsDir)) {
      for (const file of fs.readdirSync(domainsDir)) {
        if (file.endsWith('.md')) {
          const name = path.basename(file, '.md');
          const content = readMarkdown(path.join(domainsDir, file));
          const meta = readJson<Record<string, unknown>>(path.join(domainsDir, `${name}.json`));
          if (content) {
            const domain: DomainKnowledge = {
              id: (meta?.id as string) || generateId('domain', name),
              name,
              type: 'domain',
              content,
              domain: (meta?.domain as string) || name,
              ppDimension: meta?.ppDimension as PPDimension | undefined,
              tags: meta?.tags as string[] | undefined,
              createdAt: meta?.createdAt ? new Date(meta.createdAt as string) : new Date(),
              updatedAt: meta?.updatedAt ? new Date(meta.updatedAt as string) : new Date(),
            };
            knowledge.domains.push(domain);
          }
        }
      }
    }

    return knowledge;
  }

  /**
   * Load global knowledge
   */
  loadGlobal(): DirectoryKnowledge | null {
    const globalPath = path.join(this.globalPath, 'global');
    if (!fs.existsSync(globalPath)) {
      return null;
    }
    try {
      return this.load(globalPath);
    } catch {
      return null;
    }
  }

  // ==========================================================================
  // Project Registry
  // ==========================================================================

  /**
   * Register a project
   */
  registerProject(projectPath: string): void {
    const registryPath = path.join(this.globalPath, REGISTRY_FILE);
    ensureDir(path.dirname(registryPath));

    const registry = readJson<ProjectRegistryEntry[]>(registryPath) || [];
    const id = hashPath(projectPath);

    const existing = registry.findIndex(p => p.id === id);
    const entry: ProjectRegistryEntry = {
      id,
      path: projectPath,
      name: path.basename(projectPath),
      registeredAt: new Date().toISOString(),
      lastAccessedAt: new Date().toISOString(),
      directoryCount: 1,
    };

    if (existing >= 0) {
      registry[existing] = { ...registry[existing], ...entry, registeredAt: registry[existing].registeredAt };
    } else {
      registry.push(entry);
    }

    writeJson(registryPath, registry);
  }

  /**
   * Get all registered projects
   */
  getProjects(): ProjectRegistryEntry[] {
    const registryPath = path.join(this.globalPath, REGISTRY_FILE);
    return readJson<ProjectRegistryEntry[]>(registryPath) || [];
  }

  // ==========================================================================
  // Helper Methods
  // ==========================================================================

  /**
   * Update manifest counts
   */
  private updateManifestCounts(dirPath: string): void {
    const guaPath = this.getGuaPath(dirPath);
    const manifestPath = path.join(guaPath, MANIFEST_FILE);
    const manifest = readJson<DirectoryManifest>(manifestPath);

    if (!manifest) return;

    const countFiles = (subdir: string): number => {
      const dir = path.join(guaPath, subdir);
      if (!fs.existsSync(dir)) return 0;
      return fs.readdirSync(dir).filter(f => f.endsWith('.md')).length;
    };

    manifest.counts = {
      patterns: countFiles('patterns'),
      contexts: countFiles('contexts'),
      gotchas: countFiles('gotchas'),
      overrides: countFiles('overrides'),
      domains: countFiles('domains'),
    };
    manifest.updatedAt = new Date().toISOString();

    writeJson(manifestPath, manifest);
  }

  /**
   * Get manifest for a directory
   */
  getManifest(dirPath: string): DirectoryManifest | null {
    const manifestPath = path.join(this.getGuaPath(dirPath), MANIFEST_FILE);
    return readJson<DirectoryManifest>(manifestPath);
  }

  /**
   * List all directories with .gua/ under a root
   */
  listKnowledgeDirs(rootPath: string, maxDepth?: number): string[] {
    const dirs: string[] = [];
    const depth = maxDepth ?? this.config.maxDepth;

    const traverse = (current: string, currentDepth: number): void => {
      if (currentDepth > depth) return;

      // Check if this dir has .gua/
      if (this.hasKnowledge(current)) {
        dirs.push(current);
      }

      // Skip excluded patterns
      const basename = path.basename(current);
      if (this.config.excludePatterns.includes(basename)) {
        return;
      }

      // Traverse children
      try {
        const entries = fs.readdirSync(current, { withFileTypes: true });
        for (const entry of entries) {
          if (entry.isDirectory() && !entry.name.startsWith('.')) {
            traverse(path.join(current, entry.name), currentDepth + 1);
          }
        }
      } catch {
        // Skip directories we can't read
      }
    };

    traverse(rootPath, 0);
    return dirs;
  }
}

// ============================================================================
// Factory
// ============================================================================

export function createLocalStore(globalPath?: string): LocalDirectoryStore {
  return new LocalDirectoryStore(globalPath);
}

// ============================================================================
// Singleton Instance
// ============================================================================

let defaultStore: LocalDirectoryStore | null = null;

export function getLocalStore(): LocalDirectoryStore {
  if (!defaultStore) {
    defaultStore = createLocalStore();
  }
  return defaultStore;
}
