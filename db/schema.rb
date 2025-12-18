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

ActiveRecord::Schema[8.1].define(version: 2025_12_18_114038) do
  create_table "bio", force: :cascade do |t|
    t.string "brief_bio"
    t.text "content"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "blog_posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "filename"
    t.date "published_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["filename"], name: "index_blog_posts_on_filename", unique: true
  end

  create_table "conference_presentations", force: :cascade do |t|
    t.integer "conference_id", null: false
    t.datetime "created_at", null: false
    t.integer "presentation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_conference_presentations_on_conference_id"
    t.index ["presentation_id"], name: "index_conference_presentations_on_presentation_id"
  end

  create_table "conferences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "link"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["title", "year"], name: "index_conferences_on_title_and_year", unique: true
  end

  create_table "contact_info", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "github_url"
    t.string "linkedin_url"
    t.string "twitter_url"
    t.string "untapped_url"
    t.datetime "updated_at", null: false
  end

  create_table "presentations", force: :cascade do |t|
    t.text "abstract"
    t.datetime "created_at", null: false
    t.string "github_url"
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

  add_foreign_key "conference_presentations", "conferences"
  add_foreign_key "conference_presentations", "presentations"
  add_foreign_key "sessions", "users"
end
