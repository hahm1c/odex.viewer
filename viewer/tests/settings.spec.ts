// SPDX-License-Identifier: AGPL-3.0-only
import { test, expect } from '@playwright/test'

test('Check settings page', async ({ page }) => {
  await page.goto('/settings')

  // Check the main title
  await expect(page.getByRole('heading', { name: 'Settings' })).toBeVisible()

  // Check the State settings subtitle
  await expect(page.getByText('State settings')).toBeVisible()

  // Check the descriptive text
  await expect(
    page.getByText(
      'This section allows to manage the settings of UI element states'
    )
  ).toBeVisible()

  // Check that the reset button is visible
  await expect(
    page.getByRole('button', { name: 'Reset UI state to defaults' })
  ).toBeVisible()
})

test('Check settings page - reset UI state to defaults', async ({ page }) => {
  await page.goto('/settings')

  // Change UI theme to light mode (default is dark mode in tests) and verify the change
  await page.getByLabel('Switch to light mode').first().click()
  await expect(page.locator('html')).toHaveAttribute(
    'style',
    'color-scheme: light;'
  )

  // Reset the theme change
  await page.getByRole('button', { name: 'Reset UI state to defaults' }).click()

  // Check if the theme has been reset to dark mode
  await expect(page.locator('html')).toHaveAttribute(
    'style',
    'color-scheme: dark;'
  )

  await expect(page).toHaveURL(/\/settings/)
  await expect(page.getByRole('heading', { name: 'Settings' })).toBeVisible()
})
