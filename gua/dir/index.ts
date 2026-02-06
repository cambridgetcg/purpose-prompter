/**
 * Directory Knowledge Module
 * Hierarchical knowledge system that mirrors directory structures
 *
 * @example
 * ```typescript
 * import { getLocalStore, resolveKnowledge, buildKnowledgeTree } from './gua/dir';
 *
 * // Initialize a directory
 * const store = getLocalStore();
 * store.init('/path/to/project');
 *
 * // Add knowledge
 * store.add({
 *   type: 'pattern',
 *   name: 'error-handling',
 *   content: '# Error Handling\n\nAlways use try-catch...',
 *   ppDimension: 'truth',
 * });
 *
 * // Resolve effective knowledge
 * const resolved = await resolveKnowledge('/path/to/project/src/auth');
 *
 * // Build knowledge tree
 * const tree = await buildKnowledgeTree('/path/to/project');
 * ```
 */

// ============================================================================
// Type Exports
// ============================================================================

export type {
  // Core types
  KnowledgeScope,
  KnowledgeType,
  PPDimension,

  // Knowledge item types
  KnowledgeItem,
  PatternKnowledge,
  ContextKnowledge,
  GotchaKnowledge,
  OverrideKnowledge,
  DomainKnowledge,
  AnyKnowledgeItem,

  // Directory knowledge types
  DirectoryKnowledge,
  ResolvedKnowledge,
  AncestryEntry,

  // DynamoDB types
  DirectoryKnowledgeEntity,

  // Local storage types
  DirectoryManifest,
  ProjectRegistryEntry,
  DirectoryKnowledgeConfig,

  // Query types
  DirectoryQueryOptions,
  AddKnowledgeOptions,
  SyncOptions,
  SyncResult,
  SyncConflict,

  // Tree types
  KnowledgeTreeNode,

  // Store interface
  DirectoryKnowledgeStore,

  // Utility types
  PathHasher,
  TreeVisitor,
} from './types';

// ============================================================================
// Local Store Exports
// ============================================================================

export {
  // Store class
  LocalDirectoryStore,

  // Factory functions
  createLocalStore,
  getLocalStore,

  // Utility functions
  hashPath,
  generateId,
  findProjectRoot,
  calculateDepth,
} from './local-store';

// ============================================================================
// Resolver Exports
// ============================================================================

export {
  // Resolver class
  DirectoryKnowledgeResolver,

  // Factory function
  createResolver,

  // Convenience functions
  resolveKnowledge,
  getAncestry,
  buildKnowledgeTree,
  getEffectiveContext,
} from './resolver';

// ============================================================================
// Version
// ============================================================================

export const VERSION = '1.0.0';
