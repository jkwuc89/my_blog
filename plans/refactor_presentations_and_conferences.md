---
name: Refactor Presentations and Conferences
overview: Refactor presentations system to use a separate conferences table with many-to-many relationship. Add admin interface for managing conferences, update presentations admin to select conferences, and simplify public presentations page to show title, abstract, and conference info alphabetically.
todos: []
---

# Refactor Presentations and Conferences

## Overview

Refactor the presentations system to introduce a separate conferences table with a many-to-many relationship to presentations. This will allow presentations to be associated with multiple conferences, and conferences to be managed independently.

## Database Changes

### 1. Create Conferences Table

Create a new `conferences` table with:

- `title` (string, required)
- `year` (integer, required)
- `link` (string, optional - link to conference site)
- Unique index on `[title, year]` combination
- Standard timestamps

### 2. Repurpose ConferencePresentations Table

The existing `conference_presentations` table will become a join table for the many-to-many relationship:

- Keep `presentation_id` (references presentations)
- Replace `conference_name`, `conference_url`, `presented_at` with `conference_id` (references conferences)
- Remove old fields via migration

### 3. Update Presentations Table

- Remove `presented_at` column
- Keep `slides_url` and `github_url` (no changes)

## Model Changes

### 1. Create Conference Model

[`app/models/conference.rb`](app/models/conference.rb):

- Validates presence of `title` and `year`
- Validates uniqueness of `title` and `year` combination
- `has_many :conference_presentations, dependent: :destroy`
- `has_many :presentations, through: :conference_presentations`

### 2. Update Presentation Model

[`app/models/presentation.rb`](app/models/presentation.rb):

- Remove any `presented_at` validations
- Update associations:
- `has_many :conference_presentations, dependent: :destroy`
- `has_many :conferences, through: :conference_presentations`

### 3. Update ConferencePresentation Model

[`app/models/conference_presentation.rb`](app/models/conference_presentation.rb):

- Change from `belongs_to :presentation` only
- Add `belongs_to :conference`
- This becomes a pure join table model

## Admin Interface

### 1. Create Conferences Admin Controller

[`app/controllers/admin/conferences_controller.rb`](app/controllers/admin/conferences_controller.rb):

- Full CRUD operations (index, show, new, create, edit, update, destroy)
- Index page lists all conferences
- Form fields: title, year, link
- Validate unique title/year combination

### 2. Create Conferences Admin Views

[`app/views/admin/conferences/`](app/views/admin/conferences/):

- `index.html.erb` - List all conferences with edit/delete links
- `show.html.erb` - Display conference details
- `new.html.erb` - Create new conference form
- `edit.html.erb` - Edit conference form
- `_form.html.erb` - Shared form partial

### 3. Update Presentations Admin Controller

[`app/controllers/admin/presentations_controller.rb`](app/controllers/admin/presentations_controller.rb):

- Update `presentation_params` to accept `conference_ids: []` (array)
- Remove `presented_at` from permitted params
- In create/update actions, handle conference associations via `conference_ids`

### 4. Update Presentations Admin Views

[`app/views/admin/presentations/_form.html.erb`](app/views/admin/presentations/_form.html.erb):

- Remove `presented_at` field
- Add conference selection (checkboxes or multi-select)
- Display all available conferences with checkboxes, pre-checking associated ones
- Keep `slides_url` and `github_url` fields

[`app/views/admin/presentations/index.html.erb`](app/views/admin/presentations/index.html.erb):

- Update to show associated conferences (title and year)

[`app/views/admin/presentations/show.html.erb`](app/views/admin/presentations/show.html.erb):

- Display associated conferences with title and year

## Public Interface

### 1. Update Presentations Controller

[`app/controllers/presentations_controller.rb`](app/controllers/presentations_controller.rb):

- Remove filter logic (conference filtering)
- Remove sort logic (always alphabetical by title)
- Simplify to: `@presentations = Presentation.includes(:conferences).order(:title)`

### 2. Update Presentations Index View

[`app/views/presentations/index.html.erb`](app/views/presentations/index.html.erb):

- Remove filter and sort UI elements
- Update display to show:
- Title
- Abstract
- Conference title and year (for each associated conference)
- Remove slides_url and github_url display (or keep if desired - user didn't specify)
- List presentations alphabetically by title

## Routes

[`config/routes.rb`](config/routes.rb):

- Add `resources :conferences` inside `namespace :admin`
- Remove nested `conference_presentations` routes from presentations

## Migrations

1. **Create conferences table**: `rails generate migration CreateConferences title:string year:integer link:string`

- Add unique index on `[:title, :year]`
- Add timestamps

2. **Update conference_presentations table**: `rails generate migration UpdateConferencePresentationsToJoinTable`

- Remove columns: `conference_name`, `conference_url`, `presented_at`
- Add column: `conference_id:references`
- Add foreign key constraint

3. **Remove presented_at from presentations**: `rails generate migration RemovePresentedAtFromPresentations`

- Remove column: `presented_at`

## Files to Create

1. [`app/models/conference.rb`](app/models/conference.rb)
2. [`app/controllers/admin/conferences_controller.rb`](app/controllers/admin/conferences_controller.rb)
3. [`app/views/admin/conferences/index.html.erb`](app/views/admin/conferences/index.html.erb)
4. [`app/views/admin/conferences/show.html.erb`](app/views/admin/conferences/show.html.erb)
5. [`app/views/admin/conferences/new.html.erb`](app/views/admin/conferences/new.html.erb)
6. [`app/views/admin/conferences/edit.html.erb`](app/views/admin/conferences/edit.html.erb)
7. [`app/views/admin/conferences/_form.html.erb`](app/views/admin/conferences/_form.html.erb)
8. Three migration files (as described above)

## Files to Modify

1. [`app/models/presentation.rb`](app/models/presentation.rb) - Update associations, remove presented_at
2. [`app/models/conference_presentation.rb`](app/models/conference_presentation.rb) - Add conference association
3. [`app/controllers/admin/presentations_controller.rb`](app/controllers/admin/presentations_controller.rb) - Update params and associations
4. [`app/controllers/presentations_controller.rb`](app/controllers/presentations_controller.rb) - Simplify index action
5. [`app/views/admin/presentations/_form.html.erb`](app/views/admin/presentations/_form.html.erb) - Remove presented_at, add conference selection
6. [`app/views/admin/presentations/index.html.erb`](app/views/admin/presentations/index.html.erb) - Update display
7. [`app/views/admin/presentations/show.html.erb`](app/views/admin/presentations/show.html.erb) - Update display
8. [`app/views/presentations/index.html.erb`](app/views/presentations/index.html.erb) - Remove filters, update display
9. [`config/routes.rb`](config/routes.rb) - Add conferences routes, remove nested conference_presentations

## Implementation Order

1. Create migrations and run them
2. Create Conference model with validations
3. Update Presentation and ConferencePresentation models
4. Create conferences admin controller and views
5. Update presentations admin controller and views
6. Update public presentations controller and view
7. Update routes
8. Test all functionality

