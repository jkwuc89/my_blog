# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_15_131926) do
  create_table "bios", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "resume_url"
    t.datetime "updated_at", null: false
  end

  create_table "blog_posts", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "published_at"
    t.string "slug"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
  end

  create_table "conference_presentations", force: :cascade do |t|
    t.string "conference_name"
    t.string "conference_url"
    t.datetime "created_at", null: false
    t.integer "presentation_id", null: false
    t.date "presented_at"
    t.datetime "updated_at", null: false
    t.index ["presentation_id"], name: "index_conference_presentations_on_presentation_id"
  end

  create_table "contact_info", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "github_url"
    t.string "linkedin_url"
    t.string "stackoverflow_url"
    t.string "twitter_url"
    t.string "untapped_url"
    t.datetime "updated_at", null: false
  end

  create_table "presentations", force: :cascade do |t|
    t.text "abstract"
    t.datetime "created_at", null: false
    t.string "github_url"
    t.date "presented_at"
    t.string "slides_url"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "conference_presentations", "presentations"
  add_foreign_key "sessions", "users"
end
