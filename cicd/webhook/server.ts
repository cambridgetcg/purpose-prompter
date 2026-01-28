/**
 * CI/CD Webhook Server
 * Simple HTTP server for receiving GitHub webhook events
 *
 * Usage:
 *   npx ts-node webhook/server.ts
 *
 * Or import and use programmatically:
 *   import { startWebhookServer } from './webhook/server';
 *   startWebhookServer({ port: 8787 });
 */

import * as http from 'http';
import { CIWebhookHandler, createWebhookHandler } from './handler';
import type { WebhookEvent } from '../adapters/types';

// ============================================================================
// Types
// ============================================================================

export interface WebhookServerOptions {
  port?: number;
  host?: string;
  secret?: string;
  handler?: CIWebhookHandler;
  allowedWorkflows?: string[];
  allowedBranches?: string[];
  verbose?: boolean;
}

// ============================================================================
// Server
// ============================================================================

export class WebhookServer {
  private server: http.Server | null = null;
  private handler: CIWebhookHandler;
  private options: WebhookServerOptions;

  constructor(options: WebhookServerOptions = {}) {
    this.options = {
      port: parseInt(process.env.CI_WEBHOOK_PORT || '8787', 10),
      host: '0.0.0.0',
      verbose: true,
      ...options,
    };

    this.handler = options.handler || createWebhookHandler({
      secret: options.secret || process.env.CI_WEBHOOK_SECRET,
      allowedWorkflows: options.allowedWorkflows,
      allowedBranches: options.allowedBranches,
      verbose: options.verbose,
    });
  }

  /**
   * Start the webhook server
   */
  start(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.server = http.createServer(async (req, res) => {
        // Health check endpoint
        if (req.method === 'GET' && (req.url === '/' || req.url === '/health')) {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: 'ok', service: 'ci-webhook-server' }));
          return;
        }

        // Only accept POST to /webhook
        if (req.method !== 'POST' || !req.url?.startsWith('/webhook')) {
          res.writeHead(404);
          res.end('Not Found');
          return;
        }

        try {
          const body = await this.readBody(req);
          await this.handleWebhook(req, res, body);
        } catch (error) {
          this.log(`Error handling request: ${error}`);
          res.writeHead(500);
          res.end('Internal Server Error');
        }
      });

      this.server.on('error', (error) => {
        reject(error);
      });

      this.server.listen(this.options.port, this.options.host, () => {
        this.log(`Webhook server listening on http://${this.options.host}:${this.options.port}`);
        this.log('');
        this.log('Configure GitHub webhook:');
        this.log(`  Payload URL: http://<your-host>:${this.options.port}/webhook`);
        this.log('  Content type: application/json');
        this.log('  Secret: (set CI_WEBHOOK_SECRET env var)');
        this.log('  Events: Workflow runs, Workflow jobs');
        this.log('');
        resolve();
      });
    });
  }

  /**
   * Stop the webhook server
   */
  stop(): Promise<void> {
    return new Promise((resolve) => {
      if (this.server) {
        this.server.close(() => {
          this.log('Webhook server stopped');
          resolve();
        });
      } else {
        resolve();
      }
    });
  }

  /**
   * Handle incoming webhook request
   */
  private async handleWebhook(
    req: http.IncomingMessage,
    res: http.ServerResponse,
    body: string
  ): Promise<void> {
    // Get GitHub webhook headers
    const eventType = req.headers['x-github-event'] as string;
    const signature = req.headers['x-hub-signature-256'] as string;
    const deliveryId = req.headers['x-github-delivery'] as string;

    this.log(`Received ${eventType} event (delivery: ${deliveryId})`);

    // Verify signature if secret is configured
    if (!this.handler.verifySignature(body, signature)) {
      this.log('Invalid signature');
      res.writeHead(401);
      res.end('Invalid signature');
      return;
    }

    // Parse payload
    let payload: Record<string, unknown>;
    try {
      payload = JSON.parse(body);
    } catch {
      this.log('Invalid JSON payload');
      res.writeHead(400);
      res.end('Invalid JSON');
      return;
    }

    // Create webhook event
    const event: WebhookEvent = {
      event: eventType,
      action: (payload as any).action,
      payload,
      deliveryId,
      signature,
      timestamp: new Date(),
    };

    // Handle event asynchronously
    // Respond immediately to GitHub (they expect quick responses)
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ received: true }));

    // Process event in background
    try {
      await this.handler.handleEvent(event);
      this.log(`Successfully processed ${eventType} event`);
    } catch (error) {
      this.log(`Error processing event: ${error}`);
    }
  }

  /**
   * Read request body
   */
  private readBody(req: http.IncomingMessage): Promise<string> {
    return new Promise((resolve, reject) => {
      let body = '';
      req.on('data', (chunk) => {
        body += chunk.toString();
      });
      req.on('end', () => {
        resolve(body);
      });
      req.on('error', reject);
    });
  }

  private log(message: string): void {
    if (this.options.verbose) {
      console.log(`[Webhook Server] ${message}`);
    }
  }
}

// ============================================================================
// Factory & Helpers
// ============================================================================

export function createWebhookServer(options?: WebhookServerOptions): WebhookServer {
  return new WebhookServer(options);
}

export async function startWebhookServer(options?: WebhookServerOptions): Promise<WebhookServer> {
  const server = createWebhookServer(options);
  await server.start();
  return server;
}

// ============================================================================
// CLI Entry Point
// ============================================================================

// Run as CLI if executed directly
if (require.main === module) {
  const options: WebhookServerOptions = {
    port: parseInt(process.env.CI_WEBHOOK_PORT || '8787', 10),
    secret: process.env.CI_WEBHOOK_SECRET,
    verbose: true,
  };

  // Parse command line args
  const args = process.argv.slice(2);
  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--port':
      case '-p':
        options.port = parseInt(args[++i], 10);
        break;
      case '--secret':
      case '-s':
        options.secret = args[++i];
        break;
      case '--quiet':
      case '-q':
        options.verbose = false;
        break;
    }
  }

  console.log('Starting CI/CD Webhook Server...');
  console.log('');

  startWebhookServer(options)
    .then(() => {
      console.log('Press Ctrl+C to stop');
    })
    .catch((error) => {
      console.error('Failed to start server:', error);
      process.exit(1);
    });

  // Handle shutdown
  process.on('SIGINT', () => {
    console.log('\nShutting down...');
    process.exit(0);
  });
}
