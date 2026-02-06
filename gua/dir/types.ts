/**
 * Directory Knowledge Types
 * Type definitions for directory-aware knowledge architecture
 */

// ============================================================================
// Core Types
// ============================================================================

/** Scope levels for knowledge */
export type KnowledgeScope = 'global' | 'project' | 'directory';

/** Types of knowledge that can be stored */
export type KnowledgeType = 'pattern' | 'context' | 'gotcha' | 'override' | 'domain';

/** PP Dimension for categorizing knowledge */
export type PPDimension = 'truth' | 'understanding' | 'beauty' | 'justice' | 'creativity';

// ============================================================================
// Knowledge Item Types
// ============================================================================

/**
 * Base knowledge item interface
 */
export interface KnowledgeItem {
  /** Unique identifier */
  id: string;

  /** Human-readable name */
  name: string;

  /** Type of knowledge */
  type: KnowledgeType;

  /** Markdown content */
  content: string;

  /** Optional PP dimension */
  ppDimension?: PPDimension;

  /** Tags for categorization */
  tags?: string[];

  /** Creation timestamp */
  createdAt: Date;

  /** Last update timestamp */
  updatedAt: Date;

  /** Who created this */
  createdBy?: string;
}

/**
 * Pattern - reusable solution or approach
 */
export interface PatternKnowledge extends KnowledgeItem {
  type: 'pattern';
  /** When to use this pattern */
  applicability?: string;
  /** Example usage */
  example?: string;
  /** Related patterns */
  relatedPatterns?: string[];
}

/**
 * Context - background information about a directory/project
 */
export interface ContextKnowledge extends KnowledgeItem {
  type: 'context';
  /** What this context describes */
  describes: 'architecture' | 'domain' | 'conventions' | 'setup' | 'general';
}

/**
 * Gotcha - common pitfall or caveat
 */
export interface GotchaKnowledge extends KnowledgeItem {
  type: 'gotcha';
  /** Severity level */
  severity?: 'low' | 'medium' | 'high';
  /** How to avoid this gotcha */
  avoidance?: string;
  /** Related issues or bugs */
  relatedIssues?: string[];
}

/**
 * Override - local override of parent knowledge
 */
export interface OverrideKnowledge extends KnowledgeItem {
  type: 'override';
  /** ID of the knowledge item being overridden */
  overrides: string;
  /** Reason for the override */
  reason?: string;
}

/**
 * Domain - domain-specific knowledge
 */
export interface DomainKnowledge extends KnowledgeItem {
  type: 'domain';
  /** Domain area */
  domain: string;
  /** Key concepts */
  concepts?: string[];
}

// ============================================================================
// Directory Knowledge Types
// ============================================================================

/**
 * Directory knowledge container
 * Represents all knowledge for a specific directory
 */
export interface DirectoryKnowledge {
  /** Absolute path to the directory */
  path: string;

  /** Relative path from project root (empty for global/project root) */
  relativePath: string;

  /** Scope of this knowledge */
  scope: KnowledgeScope;

  /** Depth in the hierarchy (0 = global, 1 = project root, 2+ = subdirs) */
  depth: number;

  /** Project path (for project/directory scope) */
  projectPath?: string;

  /** Patterns in this directory */
  patterns: Map<string, PatternKnowledge>;

  /** Context items */
  contexts: ContextKnowledge[];

  /** Gotchas */
  gotchas: GotchaKnowledge[];

  /** Overrides of parent knowledge */
  overrides: Map<string, OverrideKnowledge>;

  /** Domain knowledge */
  domains: DomainKnowledge[];

  /** When this directory knowledge was last synced */
  lastSynced?: Date;
}

/**
 * Resolved knowledge - the effective knowledge for a directory
 * after inheritance resolution
 */
export interface ResolvedKnowledge {
  /** Target directory path */
  targetPath: string;

  /** Project root path */
  projectRoot: string;

  /** Merged patterns (name → item, with overrides applied) */
  patterns: Map<string, PatternKnowledge>;

  /** Accumulated contexts (from all levels) */
  contexts: ContextKnowledge[];

  /** Accumulated gotchas */
  gotchas: GotchaKnowledge[];

  /** Domain knowledge */
  domains: DomainKnowledge[];

  /** Map of overridden items (original ID → override) */
  overrides: Map<string, OverrideKnowledge>;

  /** Ancestry chain showing where knowledge came from */
  ancestry: AncestryEntry[];
}

/**
 * Entry in the ancestry chain
 */
export interface AncestryEntry {
  /** Path of the ancestor directory */
  path: string;

  /** Scope level */
  scope: KnowledgeScope;

  /** Depth in hierarchy */
  depth: number;

  /** Count of patterns from this level */
  patternCount: number;

  /** Count of contexts from this level */
  contextCount: number;

  /** Count of gotchas from this level */
  gotchaCount: number;

  /** Names of items that were overridden at this level */
  overriddenItems: string[];
}

// ============================================================================
// DynamoDB Entity Types
// ============================================================================

/**
 * DynamoDB entity for directory knowledge
 */
export interface DirectoryKnowledgeEntity {
  /** Primary Key: dir#{scope}#{path_hash}#{type}#{name_hash} */
  pk: string;

  /** Sort Key: meta | content | v#{version} */
  sk: string;

  /** GSI1 PK: user#{user_id}#project#{project_hash} */
  gsi1pk: string;

  /** GSI1 SK: depth#{N}#path#{relative_path} */
  gsi1sk: string;

  /** Knowledge scope */
  scope: KnowledgeScope;

  /** Project path (for project/directory scope) */
  projectPath?: string;

  /** Relative path within project */
  relativePath: string;

  /** Depth in hierarchy */
  depth: number;

  /** Type of knowledge */
  knowledgeType: KnowledgeType;

  /** Knowledge item name */
  name: string;

  /** Content (for sk=content) */
  content?: string;

  /** PP dimension */
  ppDimension?: PPDimension;

  /** Parent directory pk (for inheritance tracking) */
  inheritsFrom?: string;

  /** Parent knowledge pk this overrides */
  overrides?: string;

  /** Whether this cascades to children */
  cascade: boolean;

  /** Tags */
  tags?: string[];

  /** Metadata */
  createdAt: string;
  updatedAt: string;
  createdBy: string;
}

// ============================================================================
// Local Storage Types
// ============================================================================

/**
 * Manifest file for .gua/ directory
 */
export interface DirectoryManifest {
  /** Version of the manifest format */
  version: string;

  /** When this manifest was created */
  createdAt: string;

  /** Last modification */
  updatedAt: string;

  /** Directory this manifest describes */
  path: string;

  /** Scope */
  scope: KnowledgeScope;

  /** Counts for quick reference */
  counts: {
    patterns: number;
    contexts: number;
    gotchas: number;
    overrides: number;
    domains: number;
  };

  /** Last sync with DynamoDB */
  lastSync?: {
    timestamp: string;
    direction: 'push' | 'pull';
    success: boolean;
  };
}

/**
 * Project registry entry
 */
export interface ProjectRegistryEntry {
  /** Project identifier (hash of path) */
  id: string;

  /** Absolute path to project */
  path: string;

  /** Project name */
  name: string;

  /** When first registered */
  registeredAt: string;

  /** Last accessed */
  lastAccessedAt: string;

  /** Directory count with .gua/ */
  directoryCount: number;
}

/**
 * Global config for directory knowledge
 */
export interface DirectoryKnowledgeConfig {
  /** Version */
  version: string;

  /** Default cascade behavior */
  defaultCascade: boolean;

  /** Auto-sync with cloud */
  autoSync: boolean;

  /** Sync interval in minutes */
  syncIntervalMinutes: number;

  /** Excluded patterns (glob) */
  excludePatterns: string[];

  /** Max depth to traverse */
  maxDepth: number;
}

// ============================================================================
// Query & Options Types
// ============================================================================

/**
 * Options for querying directory knowledge
 */
export interface DirectoryQueryOptions {
  /** Target directory path */
  path: string;

  /** Project root (auto-detected if not provided) */
  projectRoot?: string;

  /** Maximum depth to traverse */
  maxDepth?: number;

  /** Include global knowledge */
  includeGlobal?: boolean;

  /** Filter by knowledge type */
  types?: KnowledgeType[];

  /** Filter by PP dimension */
  ppDimension?: PPDimension;

  /** Filter by tags */
  tags?: string[];
}

/**
 * Options for adding knowledge
 */
export interface AddKnowledgeOptions {
  /** Directory path (defaults to current) */
  path?: string;

  /** Type of knowledge */
  type: KnowledgeType;

  /** Name of the knowledge item */
  name: string;

  /** Content (markdown) */
  content: string;

  /** PP dimension */
  ppDimension?: PPDimension;

  /** Tags */
  tags?: string[];

  /** For overrides: which item to override */
  overrides?: string;

  /** Should this cascade to children? */
  cascade?: boolean;
}

/**
 * Options for sync operations
 */
export interface SyncOptions {
  /** Direction of sync */
  direction: 'push' | 'pull' | 'both';

  /** Force overwrite conflicts */
  force?: boolean;

  /** Recursive sync */
  recursive?: boolean;

  /** Dry run */
  dryRun?: boolean;
}

// ============================================================================
// Tree Visualization Types
// ============================================================================

/**
 * Tree node for visualization
 */
export interface KnowledgeTreeNode {
  /** Directory name */
  name: string;

  /** Full path */
  path: string;

  /** Whether this directory has .gua/ */
  hasKnowledge: boolean;

  /** Knowledge summary if present */
  knowledge?: {
    patternCount: number;
    contextCount: number;
    gotchaCount: number;
    overrideCount: number;
    domainCount: number;
    patternNames: string[];
    gotchaNames: string[];
  };

  /** Child directories */
  children: KnowledgeTreeNode[];

  /** Depth in tree */
  depth: number;
}

// ============================================================================
// Store Interface
// ============================================================================

/**
 * Interface for directory knowledge storage
 */
export interface DirectoryKnowledgeStore {
  /** Initialize .gua/ in a directory */
  init(path: string, options?: { template?: string }): Promise<void>;

  /** Check if directory has .gua/ */
  hasKnowledge(path: string): Promise<boolean>;

  /** Load knowledge for a directory */
  load(path: string): Promise<DirectoryKnowledge>;

  /** Save knowledge to a directory */
  save(knowledge: DirectoryKnowledge): Promise<void>;

  /** Add a knowledge item */
  add(options: AddKnowledgeOptions): Promise<KnowledgeItem>;

  /** Remove a knowledge item */
  remove(path: string, type: KnowledgeType, name: string): Promise<boolean>;

  /** Resolve effective knowledge (with inheritance) */
  resolve(options: DirectoryQueryOptions): Promise<ResolvedKnowledge>;

  /** Get ancestry chain */
  getAncestry(path: string): Promise<AncestryEntry[]>;

  /** Build knowledge tree */
  tree(rootPath: string, maxDepth?: number): Promise<KnowledgeTreeNode>;

  /** Sync with remote storage */
  sync(path: string, options: SyncOptions): Promise<SyncResult>;
}

/**
 * Result of a sync operation
 */
export interface SyncResult {
  success: boolean;
  direction: 'push' | 'pull' | 'both';
  itemsPushed: number;
  itemsPulled: number;
  conflicts: SyncConflict[];
  errors: string[];
}

/**
 * Sync conflict
 */
export interface SyncConflict {
  path: string;
  type: KnowledgeType;
  name: string;
  localTimestamp: Date;
  remoteTimestamp: Date;
  resolution?: 'local' | 'remote' | 'skip';
}

// ============================================================================
// Utility Types
// ============================================================================

/** Hash function for paths */
export type PathHasher = (path: string) => string;

/** Knowledge item union type */
export type AnyKnowledgeItem =
  | PatternKnowledge
  | ContextKnowledge
  | GotchaKnowledge
  | OverrideKnowledge
  | DomainKnowledge;

/** Callback for tree traversal */
export type TreeVisitor = (node: KnowledgeTreeNode) => void | Promise<void>;
