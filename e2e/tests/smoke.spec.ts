/**
 * Smoke Tests
 * Basic tests to verify the application is working
 */

import { test, expect } from '../fixtures';

test.describe('Smoke Tests', () => {
  test('homepage loads successfully', async ({ page, collectLogs }) => {
    // Navigate to homepage
    await page.goto('/');

    // Wait for page to be ready
    await page.waitForLoadState('networkidle');

    // Check that the page loaded (customize based on your app)
    const title = await page.title();
    expect(title).toBeTruthy();

    // Verify no errors in logs
    const logs = await collectLogs();
    const errors = logs.filter(l => l.level === 'error');

    if (errors.length > 0) {
      console.log('Errors found:', errors.map(e => e.message));
    }

    // Uncomment to fail on any errors:
    // expect(errors).toHaveLength(0);
  });

  test('page has no console errors', async ({ page, getErrors }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');

    // Give page time to execute scripts
    await page.waitForTimeout(1000);

    const errors = await getErrors();

    // Filter out expected errors if needed
    const unexpectedErrors = errors.filter(e =>
      !e.message.includes('Expected error') &&
      !e.message.includes('Third-party script')
    );

    expect(unexpectedErrors).toHaveLength(0);
  });

  test('navigation works', async ({ page }) => {
    await page.goto('/');

    // Find and click a navigation link (customize based on your app)
    const navLink = page.locator('nav a').first();

    if (await navLink.count() > 0) {
      const href = await navLink.getAttribute('href');
      await navLink.click();

      // Verify navigation occurred
      await page.waitForLoadState('networkidle');
      expect(page.url()).toContain(href || '');
    } else {
      // Skip if no nav links
      test.skip();
    }
  });

  test('responsive design - mobile viewport', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });

    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');

    // Check that content is visible
    const body = page.locator('body');
    await expect(body).toBeVisible();

    // Check no horizontal scroll (content fits viewport)
    const scrollWidth = await page.evaluate(() => document.body.scrollWidth);
    const viewportWidth = 375;

    // Allow small margin for scrollbars
    expect(scrollWidth).toBeLessThanOrEqual(viewportWidth + 20);
  });
});

test.describe('API Health', () => {
  test('health endpoint responds', async ({ page, request }) => {
    // Try common health check endpoints
    const healthEndpoints = ['/api/health', '/health', '/api/status', '/_health'];

    let healthResponse = null;

    for (const endpoint of healthEndpoints) {
      try {
        const response = await request.get(endpoint);
        if (response.ok()) {
          healthResponse = response;
          break;
        }
      } catch {
        // Try next endpoint
      }
    }

    if (healthResponse) {
      expect(healthResponse.ok()).toBeTruthy();
    } else {
      // Skip if no health endpoint found
      test.skip();
    }
  });
});

test.describe('Performance', () => {
  test('page loads within acceptable time', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    const loadTime = Date.now() - startTime;

    // Page should load within 5 seconds
    expect(loadTime).toBeLessThan(5000);

    // Log for monitoring
    console.log(`Page load time: ${loadTime}ms`);
  });

  test('no large layout shifts', async ({ page }) => {
    await page.goto('/');

    // Get CLS metric
    const cls = await page.evaluate(() => {
      return new Promise<number>((resolve) => {
        let clsValue = 0;

        const observer = new PerformanceObserver((list) => {
          for (const entry of list.getEntries()) {
            if (!(entry as any).hadRecentInput) {
              clsValue += (entry as any).value;
            }
          }
        });

        observer.observe({ type: 'layout-shift', buffered: true });

        // Wait a bit then resolve
        setTimeout(() => {
          observer.disconnect();
          resolve(clsValue);
        }, 2000);
      });
    });

    // CLS should be under 0.1 for good UX
    expect(cls).toBeLessThan(0.1);
  });
});
