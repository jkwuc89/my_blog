---
name: Add Untappd Support
overview: Rename contact_infos table and all related files/directories to contact_info (singular), rename untapped_username field to untapped_url for consistency, update admin forms to use "Untapped" label and URL field type, and add Untappd logo to footer next to X logo.
todos:
  - id: table_rename
    content: Create migration to rename contact_infos table to contact_info
    status: completed
  - id: model_table_name
    content: Update ContactInfo model to specify table_name as contact_info
    status: completed
  - id: rename_controller_file
    content: Rename app/controllers/admin/contact_infos_controller.rb to contact_info_controller.rb
    status: completed
  - id: rename_controller_class
    content: Update controller class name from ContactInfosController to ContactInfoController
    status: completed
  - id: rename_views_directory
    content: Rename app/views/admin/contact_infos/ directory to contact_info/
    status: completed
  - id: migration
    content: Create migration to rename untapped_username to untapped_url column
    status: completed
  - id: controller
    content: Update contact_info_controller to permit untapped_url instead of untapped_username
    status: completed
  - id: admin_edit
    content: "Update admin edit view: change label to 'Untapped' and use url_field"
    status: completed
  - id: admin_show
    content: "Update admin show view: change label to 'Untapped' and display as URL link"
    status: completed
  - id: about_page
    content: Update about page to use untapped_url and display as clickable link
    status: completed
  - id: footer
    content: Add Untappd logo to footer after X logo, linking to untapped_url
    status: completed
  - id: fixtures
    content: Rename test fixture file from contact_infos.yml to contact_info.yml and update field name
    status: completed
---

# Add Untappd Support

## Overview

This plan renames the contact_infos table and all related files/directories to contact_info (singular), updates the contact info system to store Untappd profile URLs instead of usernames, and adds an Untappd logo to the footer.

## Changes Required

### 1. Database Table Rename

- Create a migration to rename the `contact_infos` table to `contact_info` (singular)
- File: `db/migrate/YYYYMMDDHHMMSS_rename_contact_infos_to_contact_info.rb`
- Update [app/models/contact_info.rb](app/models/contact_info.rb) to explicitly set `self.table_name = 'contact_info'` since Rails expects plural table names by default

### 1a. File and Directory Renames

- Rename `app/controllers/admin/contact_infos_controller.rb` to `app/controllers/admin/contact_info_controller.rb`
- Update the controller class name from `Admin::ContactInfosController` to `Admin::ContactInfoController` in the renamed file
- Rename `app/views/admin/contact_infos/` directory to `app/views/admin/contact_info/`
- Rename `test/fixtures/contact_infos.yml` to `test/fixtures/contact_info.yml`
- Note: The migration file `db/migrate/20251212195027_create_contact_infos.rb` should remain as-is (migration files are timestamped and typically not renamed after creation)

### 2. Database Migration

- Create a migration to rename `untapped_username` column to `untapped_url` in the `contact_info` table
- File: `db/migrate/YYYYMMDDHHMMSS_rename_untapped_username_to_untapped_url.rb`

### 3. Controller Updates

- Update [app/controllers/admin/contact_info_controller.rb](app/controllers/admin/contact_info_controller.rb) (after renaming)
- Change `contact_info_params` to permit `:untapped_url` instead of `:untapped_username`

### 4. Admin Views Updates

- Update [app/views/admin/contact_info/edit.html.erb](app/views/admin/contact_info/edit.html.erb) (after directory rename)
- Change label from "Untappd Username" to "Untapped"
- Change `text_field` to `url_field` for the untapped field
- Update [app/views/admin/contact_info/show.html.erb](app/views/admin/contact_info/show.html.erb) (after directory rename)
- Change label from "Untappd Username" to "Untapped"
- Display as a clickable URL link (similar to other social links)

### 5. Public Pages Updates

- Update [app/views/pages/about.html.erb](app/views/pages/about.html.erb)
- Change reference from `untapped_username` to `untapped_url`
- Display as a clickable URL link instead of plain text

### 6. Footer Updates

- Update [app/views/layouts/_footer.html.erb](app/views/layouts/_footer.html.erb)
- Add Untappd logo link after the Twitter/X logo (before Stack Overflow)
- Use the SVG from `app/assets/images/Untappd.svg`
- Link to `contact_info.untapped_url` when present
- Style consistently with other footer icons (w-6 h-6, same hover effects)

### 7. Test Fixtures

- Update fixture file `test/fixtures/contact_info.yml` (after renaming) to use `untapped_url` instead of `untapped_username`

## Implementation Notes

- The Untappd logo SVG is already present at `app/assets/images/Untappd.svg`
- Footer icons are displayed in a flex container with consistent spacing
- All URL fields follow the same pattern: conditional rendering with `present?` check
- The footer uses inline SVG for other icons, but we'll use `image_tag` or `image_path` for the Untappd SVG file
- The table rename from `contact_infos` to `contact_info` is non-standard Rails convention (Rails typically uses plural table names), so the model must explicitly specify the table name using `self.table_name = 'contact_info'`
- Both migrations (table rename and column rename) can be combined into a single migration if preferred, or kept separate for clarity
- The routes file already uses `resource :contact_info` (singular), so no route changes are needed
- After renaming files and directories, ensure all references are updated (controller class name, view paths, etc.)

## Implementation Status

All tasks have been completed. The migrations need to be run to update the database:

```bash
rails db:migrate
```

This will update the database schema and `db/schema.rb` automatically.

