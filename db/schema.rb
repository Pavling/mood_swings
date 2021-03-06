# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140616103400) do

  create_table "answer_sets", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "cohort_id"
  end

  add_index "answer_sets", ["user_id"], :name => "index_answer_sets_on_user_id"

  create_table "answers", :force => true do |t|
    t.integer  "answer_set_id"
    t.integer  "metric_id"
    t.integer  "value"
    t.text     "comments"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "answers", ["answer_set_id"], :name => "index_answers_on_answer_set_id"
  add_index "answers", ["metric_id"], :name => "index_answers_on_metric_id"

  create_table "campus_administrators", :force => true do |t|
    t.integer  "administrator_id"
    t.integer  "campus_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "campus_administrators", ["administrator_id"], :name => "index_campus_administrators_on_administrator_id"
  add_index "campus_administrators", ["campus_id"], :name => "index_campus_administrators_on_campus_id"

  create_table "campuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cohort_administrators", :force => true do |t|
    t.integer  "administrator_id"
    t.integer  "cohort_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "cohort_administrators", ["administrator_id"], :name => "index_cohort_administrators_on_administrator_id"
  add_index "cohort_administrators", ["cohort_id"], :name => "index_cohort_administrators_on_cohort_id"

  create_table "cohorts", :force => true do |t|
    t.string   "name"
    t.date     "start_on"
    t.date     "end_on"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.integer  "campus_id"
    t.boolean  "skip_email_reminders",                  :default => false
    t.boolean  "allow_users_to_manage_email_reminders", :default => true
  end

  create_table "metrics", :force => true do |t|
    t.string   "measure"
    t.boolean  "active",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,     :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "role"
    t.datetime "reminder_email_sent_at"
    t.boolean  "skip_email_reminders",   :default => false
    t.integer  "cohort_id"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      :default => 0
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token", :unique => true
  add_index "users", ["invitations_count"], :name => "index_users_on_invitations_count"
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
