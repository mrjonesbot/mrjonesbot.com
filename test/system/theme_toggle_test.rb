require "application_system_test_case"

class ThemeToggleTest < ApplicationSystemTestCase
  test "theme toggle switches between light and dark mode" do
    # Navigate to the homepage
    visit root_url

    # Take initial screenshot
    take_screenshot("01-initial-state")

    # Check initial data-theme attribute on html element
    initial_theme = page.evaluate_script("document.documentElement.dataset.theme")
    puts "\n=== Initial theme: #{initial_theme || 'not set'} ==="

    # Find and click the theme toggle button
    # The button has data-action="click->theme#toggle" and is in the top-right corner
    toggle_button = find("button[data-action='click->theme#toggle']")
    assert toggle_button, "Theme toggle button should be present"

    # Click the toggle
    toggle_button.click

    # Wait for any transitions/animations
    sleep 0.5

    # Check the new data-theme attribute
    new_theme = page.evaluate_script("document.documentElement.dataset.theme")
    puts "=== New theme: #{new_theme || 'not set'} ==="

    # Take screenshot after toggle
    take_screenshot("02-after-toggle")

    # Verify the theme actually changed
    assert_not_equal initial_theme, new_theme, "Theme should have changed from #{initial_theme} to something else"

    # Verify it toggled to the opposite theme
    if initial_theme == "light"
      assert_equal "dark", new_theme, "Should have switched to dark theme"
    elsif initial_theme == "dark"
      assert_equal "light", new_theme, "Should have switched to light theme"
    end

    # Verify localStorage was updated
    stored_theme = page.evaluate_script("localStorage.getItem('theme')")
    puts "=== Stored theme in localStorage: #{stored_theme || 'not set'} ==="
    assert_equal new_theme, stored_theme, "Theme should be persisted to localStorage"

    # Click again to verify it toggles back
    toggle_button.click
    sleep 0.5

    final_theme = page.evaluate_script("document.documentElement.dataset.theme")
    puts "=== Final theme after second toggle: #{final_theme || 'not set'} ==="

    take_screenshot("03-after-second-toggle")

    assert_equal initial_theme, final_theme, "Should toggle back to initial theme"
  end

  private

  def take_screenshot(name)
    # Capybara screenshot helper
    page.save_screenshot(Rails.root.join("tmp/screenshots/#{name}.png"))
    puts "Screenshot saved: tmp/screenshots/#{name}.png"
  end
end
