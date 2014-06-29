require 'spec_helper'

describe User do
  it "has a valid factory" do
    expect(FactoryGirl.build(:user)).to be_valid
  end

  it "can destroy if there are no answer_sets" do
    user = FactoryGirl.create(:user)    
    expect(user.destroy).to be user
  end

  it "cannot destroy if there are answer_sets" do
    user = FactoryGirl.create(:user_with_answer_sets)
    expect(user.destroy).to be false
  end
  
  it "is invalid without a name" do
    expect(FactoryGirl.build(:user, name: nil)).to_not be_valid
  end

  describe '.unenrolled' do
    it "returns all students who are not enrolled in a cohort" do
      user = FactoryGirl.create(:user)
      2.times { FactoryGirl.create(:user, cohort: FactoryGirl.create(:cohort)) }

      expect(User.unenrolled).to eq [user]
    end
  end

  describe '.desiring_email_reminder' do
    describe "cohort allows students to manage email reminders" do
      before :each do
        @cohort = FactoryGirl.create(:cohort, allow_users_to_manage_email_reminders: true)
        @user = FactoryGirl.create(:user, cohort: @cohort)
        @skip_email_users = 2.times.map { FactoryGirl.create(:user, cohort: @cohort, skip_email_reminders: true) }
      end

      it "returns all students who are configured to receive email reminders" do
        expect(User.desiring_email_reminder).to include @user
      end

      it "doesn't return students who are configured to skip email reminders" do
        expect(User.desiring_email_reminder).to_not include @skip_email_users.sample
      end
    end

    describe "cohort doesn't allow students to manage email reminders" do
      describe "cohort skips email reminders" do
        before :each do
          @cohort = FactoryGirl.create(:cohort, allow_users_to_manage_email_reminders: false, skip_email_reminders: true)
          @user = FactoryGirl.create(:user, cohort: @cohort)
          @skip_email_users = 2.times.map { FactoryGirl.create(:user, cohort: @cohort, skip_email_reminders: true) }
        end

        it "doesn't return students who are configured to receive email reminders" do
          expect(User.desiring_email_reminder).to_not include @user
        end

        it "doesn't return students who are configured to skip email reminders" do
          expect(User.desiring_email_reminder).to_not include @skip_email_users.sample
        end
      end

      describe "cohort doesn't skip email reminders" do
        before :each do
          @cohort = FactoryGirl.create(:cohort, allow_users_to_manage_email_reminders: false, skip_email_reminders: false)
          @user = FactoryGirl.create(:user, cohort: @cohort)
          @skip_email_users = 2.times.map { FactoryGirl.create(:user, cohort: @cohort, skip_email_reminders: true) }
        end

        it "returns students who are configured to receive email reminders" do
          expect(User.desiring_email_reminder).to include @user
        end

        it "returns students who are configured to skip email reminders" do
          expect(User.desiring_email_reminder).to include @skip_email_users.sample
        end
      end
    end

    it "doesn't allow users to change their skip_email_reminders setting if the cohort prohibits it"

    it "sets the user's skip_email_reminders value to the same as the user's cohort if the cohort doesn't allow users to manage their own"

  end

  describe 'default scope' do
    it 'orders by user name' do
      names = (?a..?z).to_a
      names.shuffle.each do |name|
        FactoryGirl.create(:user, name: name)
      end
      expect(User.all.map(&:name)).to eq names
    end
  end

  describe '#first_name' do
    it 'return the first part of the name (up until the first space)' do
      first_name = Faker::Name.first_name
      name = "#{first_name} #{Faker::Name.last_name}"
      user = FactoryGirl.build(:user, name: name)
      expect(user.first_name).to eq first_name
    end
  end

  describe '#last_answer_set' do
    before :each do
      @user = FactoryGirl.create(:user)
      3.times do |i| 
        as = FactoryGirl.create(:answer_set, :with_answers, user: @user) 
        as.update_attribute(:created_at, ((i+1)*5).minutes.ago)
      end
      @answer_set = FactoryGirl.create(:answer_set, :with_answers, user: @user)
    end

    it 'returns the most recently created answer set for the user' do
      expect(@user.last_answer_set).to eq @answer_set
    end

    it 'returns the most recently created answer set for the user, even if other users have more recent answer sets' do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:answer_set, :with_answers, user: user)

      expect(@user.last_answer_set).to eq @answer_set
    end
  end

  describe '#default_cohort_granularity' do
    it 'returns the correct value for admins' do
      user = FactoryGirl.build(:admin_user)
      expect(user.default_cohort_granularity).to eq :cohort
    end

    it 'returns the correct value for cohort_admins' do
      user = FactoryGirl.create(:cohort_admin_user)
      expect(user.default_cohort_granularity).to eq :cohort
    end

    it 'returns the correct value for plain users' do
      user = FactoryGirl.build(:user)
      expect(user.default_cohort_granularity).to eq :person
    end
  end

  describe '#admin?' do
    it 'returns true for admins' do
      expect(FactoryGirl.build(:admin_user).admin?).to be_true
    end

    it 'returns false for plain users' do
      expect(FactoryGirl.build(:user).admin?).to be_false
    end

    it 'returns false for invalid roles' do
      (Faker::Lorem.words - %w(admin)).each do |word|
        expect(FactoryGirl.build(:user, role: word).admin?).to be_false
      end
    end
  end

  describe '#cohort_admin?' do
    describe 'for cohort admins' do
      it 'returns true if the user is administering any cohorts' do
        expect(FactoryGirl.create(:cohort_admin_user).cohort_admin?).to be_true
      end
    end

    describe 'for non-cohort admins' do
      it 'returns false for plain users who are not administering any cohorts' do
        expect(FactoryGirl.build(:user).cohort_admin?).to be_false
      end

      it 'returns false for admin users who are not administering any cohorts' do
        expect(FactoryGirl.build(:admin_user).cohort_admin?).to be_false
      end
    end
  end

  describe '#campus_admin?' do
    describe 'for campus admins' do
      it 'returns true if the user is administering any campus' do
        expect(FactoryGirl.create(:campus_admin_user).campus_admin?).to be_true
      end
    end

    describe 'for non-campus admins' do
      it 'returns false for plain users who are not administering any campus' do
        expect(FactoryGirl.build(:user).campus_admin?).to be_false
      end

      it 'returns false for admin users who are not administering any campus' do
        expect(FactoryGirl.build(:admin_user).campus_admin?).to be_false
      end
    end
  end

  describe '#can_manage_email_reminders' do
    it 'can manage email reminders when cohort allows it' do
      cohort = FactoryGirl.build(:cohort, allow_users_to_manage_email_reminders: true)
      expect(FactoryGirl.build(:user, cohort: cohort).can_manage_email_reminders?).to be_true
    end

    it 'cannot manage email reminders when cohort prevents it' do
      cohort = FactoryGirl.build(:cohort, allow_users_to_manage_email_reminders: false)
      expect(FactoryGirl.build(:user, cohort: cohort).can_manage_email_reminders?).to be_false
    end
  end


  describe '.needing_reminder_email' do#
    before :each do
      campus =  FactoryGirl.create(:campus)
      @cohort = FactoryGirl.create(:cohort, campus: campus)
      @cohort2 = FactoryGirl.create(:cohort, campus: campus, allow_users_to_manage_email_reminders: false)
      @cohort3 = FactoryGirl.create(:cohort, campus: campus, allow_users_to_manage_email_reminders: false, skip_email_reminders: true)

      @user1 = FactoryGirl.create(:user, cohort: @cohort)
      @user2 = FactoryGirl.create(:user_with_answer_sets, cohort: @cohort)
      @user3 = FactoryGirl.create(:user_with_answer_sets, cohort: @cohort)
      @user3.answer_sets.map do |as|
        as.update_attribute(:created_at, Time.zone.now.ago(1.day).ago(10.minutes))
      end
      @user4 = FactoryGirl.create(:user_with_answer_sets, cohort: @cohort)
      @user4.answer_sets.map do |as|
        as.update_attribute(:created_at, Time.zone.now.ago(1.day).since(10.minutes))
      end
      @user5 = FactoryGirl.create(:user, cohort: @cohort2)
      @user6 = FactoryGirl.create(:user, cohort: @cohort3)
    end

    it 'includes a user with no answer_sets' do
      expect(User.needing_reminder_email).to include @user1
    end

    it 'includes a user with answer_sets over 24hours old' do
      expect(User.needing_reminder_email).to include @user3
    end

    it "doesn't include a user who has recent answer_sets" do
      expect(User.needing_reminder_email).to_not include @user2
    end

    it "doesn't include a user who has answer_sets just under 24hours old" do
      expect(User.needing_reminder_email).to_not include @user4
    end

    it "includes a user on a cohort that doesn't allow users to manage email reminders" do
      expect(User.needing_reminder_email).to include @user5
    end

    it "doesn't include a user on a cohort that doesn't allow users to manage email reminders and skips email reminders" do
      expect(User.needing_reminder_email).to_not include @user6
    end
  end


  describe '.mood_swung_today' do
    it 'returns only users who have swung their mood today' do
      FactoryGirl.create(:user)
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)

      FactoryGirl.create(:answer_set, :with_answers, user: user1)

      answer_set = FactoryGirl.create(:answer_set, :with_answers, user: user2)
      answer_set.update_attribute(:created_at, 2.days.ago)

      expect(User.mood_swung_today).to eq [user1]
    end
  end


  describe 'accessibility' do
    before :each do
      @campus1 = FactoryGirl.create(:campus)
      @campus2 = FactoryGirl.create(:campus)

      @cohort1 = FactoryGirl.create(:cohort, campus: @campus1)
      @cohort2 = FactoryGirl.create(:past_cohort, campus: @campus1)
      @cohort3 = FactoryGirl.create(:future_cohort, campus: @campus2)

      @admin = FactoryGirl.create(:admin_user)

      @campus_admin = FactoryGirl.create(:user, cohort: nil)
      @campus_admin.administered_campuses << @campus1

      @cohort_admin = FactoryGirl.create(:user, cohort: nil)
      @cohort_admin.administered_cohorts << @cohort1
      @cohort_admin.administered_cohorts << @cohort3

      @user1 = FactoryGirl.create(:user_with_answer_sets, cohort: @cohort1)
      @user2 = FactoryGirl.create(:user_with_answer_sets, cohort: @cohort2)
      @user3 = FactoryGirl.create(:user_with_answer_sets, cohort: @cohort3)
      @user4 = FactoryGirl.create(:user_with_answer_sets, cohort: @cohort1)

      @user4.administered_cohorts << @cohort3
    end


    describe '#accessible_campuses' do
      describe 'admin' do
        it 'returns all campuses' do
          ids = [@campus1, @campus2].map(&:id)
          expect(@admin.accessible_campuses.map(&:id).sort).to eq ids
        end
      end

      describe 'campus_admin' do
        it 'returns all current and future cohorts accessible to the campus_admin' do
          ids = [@campus1.id]
          expect(@campus_admin.accessible_campuses.map(&:id).sort).to eq ids
        end
      end

      describe 'cohort_admin' do
        it 'returns all current and future cohorts accessible to the cohort_admin' do
          ids = [@campus1, @campus2].map(&:id).sort
          expect(@cohort_admin.accessible_campuses.map(&:id).sort).to eq ids
        end

        it 'returns all accessible current and future cohorts even if user is on cohort themselves' do
          ids = [@campus2.id]
          expect(@user4.accessible_campuses.map(&:id).sort).to eq ids
        end
      end

      describe 'user' do
        describe 'for users on current and future cohorts' do
          it 'returns no campuses' do
            [@user1, @user3].each do |user|
              expect(user.accessible_campuses.map(&:id)).to be_empty
            end
          end

          describe 'for users on past cohorts' do
            it 'returns no campuses' do
              expect(@user2.accessible_campuses).to be_empty
            end
          end
        end
      end
    end


    describe '#invitable_cohorts' do
      describe 'admin' do
        it 'returns all current and future cohorts' do
          ids = [@cohort1, @cohort3].map(&:id)
          expect(@admin.invitable_cohorts.map(&:id).sort).to eq ids
        end
      end

      describe 'campus_admin' do
        it 'returns all current and future cohorts accessible to the campus_admin' do
          ids = [@cohort1.id]
          expect(@campus_admin.invitable_cohorts.map(&:id).sort).to eq ids
        end
      end

      describe 'cohort_admin' do
        it 'returns all current and future cohorts accessible to the cohort_admin' do
          ids = [@cohort1, @cohort3].map(&:id).sort
          expect(@cohort_admin.invitable_cohorts.map(&:id).sort).to eq ids
        end

        it 'returns all accessible current and future cohorts even if user is on cohort themselves' do
          ids = [@cohort1, @cohort3].map(&:id).sort
          expect(@user4.invitable_cohorts.map(&:id).sort).to eq ids
        end
      end

      describe 'user' do
        describe 'for users on current and future cohorts' do
          it 'returns own cohort' do
            [@user1, @user3].each do |user|
              expect(user.invitable_cohorts.map(&:id)).to eq [user.cohort.id]
            end
          end

          describe 'for users on past cohorts' do
            it 'returns no cohorts' do
              expect(@user2.invitable_cohorts).to be_empty
            end
          end
        end
      end
    end


    describe '#accessible_answer_sets' do
      describe 'admin' do
        it 'returns all answer_sets' do
          ids = AnswerSet.all.map(&:id).sort
          expect(@admin.accessible_answer_sets.map(&:id).sort).to eq ids
        end
      end

      describe 'campus_admin' do
        it 'returns all answer_sets for the campus' do
          ids = [@user1, @user2, @user4].flat_map(&:answer_sets).map(&:id).sort
          expect(@campus_admin.accessible_answer_sets.map(&:id).sort).to eq ids
        end
      end

      describe 'cohort_admin' do
        it 'returns all answer_sets for the administered cohorts' do
          ids = [@user1, @user3, @user4].flat_map(&:answer_sets).map(&:id).sort
          expect(@cohort_admin.accessible_answer_sets.map(&:id).sort).to eq ids
        end

        it 'returns all answer_sets for the administered cohorts and own if user is on cohort themselves' do
          ids = [@user3, @user4].flat_map(&:answer_sets).map(&:id).sort
          expect(@user4.accessible_answer_sets.map(&:id).sort).to eq ids
        end
      end

      describe 'user' do
        it 'returns own answer_sets' do
          [@user1, @user2, @user3].each do |user|
            expect(user.accessible_answer_sets.map(&:id).sort).to eq user.answer_sets.map(&:id).sort
          end
        end
      end
    end


    describe '#accessible_users' do
      describe 'admin' do
        it 'returns all users' do
          ids = [@admin, @campus_admin, @cohort_admin, @user1, @user2, @user3, @user4].map(&:id).sort
          expect(@admin.accessible_users.map(&:id).sort).to eq ids
        end
      end

      describe 'campus_admin' do
        it 'returns all users for the campus' do
          ids = [@user1, @user2, @user4].map(&:id).sort
          expect(@campus_admin.accessible_users.map(&:id).sort).to eq ids
        end
      end

      describe 'cohort_admin' do
        it 'returns all users for the administered cohorts' do
          ids = [@user1, @user3, @user4].map(&:id).sort
          expect(@cohort_admin.accessible_users.map(&:id).sort).to eq ids
        end

        it 'returns all users for the cohort even if user is on cohort themselves' do
          ids = [@user3.id]
          expect(@user4.accessible_users.map(&:id).sort).to eq ids
        end
      end

      describe 'user' do
        it 'returns no users' do
          [@user1, @user2, @user3].each do |user|
            expect(user.accessible_users).to be_empty
          end
        end
      end
    end


    describe '#accessible_cohorts' do
      describe 'admin' do
        it 'returns all cohorts' do
          ids = [@cohort1, @cohort2, @cohort3].map(&:id).sort
          expect(@admin.accessible_cohorts.map(&:id).sort).to eq ids
        end
      end

      describe 'campus_admin' do
        it 'returns all accessible cohorts for the campus' do
          ids = [@cohort1, @cohort2].map(&:id).sort
          expect(@campus_admin.accessible_cohorts.map(&:id).sort).to eq ids
        end
      end

      describe 'cohort_admin' do
        it 'returns all the administered cohorts' do
          ids = [@cohort1, @cohort3].map(&:id).sort
          expect(@cohort_admin.accessible_cohorts.map(&:id).sort).to eq ids
        end

        it 'returns all the administered cohorts and own cohort if user is on cohort themselves' do
          ids = [@cohort1, @cohort3].map(&:id).sort
          expect(@user4.accessible_cohorts.map(&:id).sort).to eq ids
        end
      end

      describe 'user' do
        it 'returns own cohort' do
          [@user1, @user2, @user3].each do |user|
            expect(user.accessible_cohorts.map(&:id)).to eq [user.cohort.id]
          end
        end
      end
    end


    describe '#accessible_cohorts_by_campus' do
      describe 'admin' do
        it 'returns all cohorts grouped by campus' do
          hash = flatten_hash_to_ids({ @campus1 => [@cohort1, @cohort2], @campus2 => [@cohort3] })
          expect(flatten_hash_to_ids(@admin.accessible_cohorts_by_campus)).to eq hash
        end
      end

      describe 'campus_admin' do
        it 'returns all accessible cohorts for the campus grouped by campus' do
          hash = flatten_hash_to_ids({ @campus1 => [@cohort1, @cohort2] })
          expect(flatten_hash_to_ids(@campus_admin.accessible_cohorts_by_campus)).to eq hash
        end
      end

      describe 'cohort_admin' do
        it 'returns all the administered cohorts grouped by campus' do
          hash = flatten_hash_to_ids({ @campus1 => [@cohort1], @campus2 => [@cohort3] })
          expect(flatten_hash_to_ids(@cohort_admin.accessible_cohorts_by_campus)).to eq hash
        end

        it 'returns all the administered cohorts and own cohort if user is on cohort themselves' do
          hash = flatten_hash_to_ids({ @campus1 => [@cohort1], @campus2 => [@cohort3] })
          expect(flatten_hash_to_ids(@user4.accessible_cohorts_by_campus)).to eq hash
        end
      end

      describe 'user' do
        it 'returns own cohort' do
          [@user1, @user2, @user3].each do |user|
            expect(flatten_hash_to_ids(user.accessible_cohorts_by_campus)).to eq({ user.cohort.campus.id => [user.cohort.id] })
          end
        end
      end
    end


    describe '#default_cohort_ids_for_filter' do
      describe 'with running cohorts' do
        before :each do
          @cohort4 = FactoryGirl.create(:cohort, campus: @campus1)
        end

        describe 'admin' do
          it 'returns ids for all currently running cohorts' do
            ids = [@cohort1, @cohort4].map { |c| c.id.to_s }.sort
            expect(@admin.default_cohort_ids_for_filter.sort).to eq ids
          end
        end

        describe 'campus_admin' do
          it 'returns ids for all currently running accessible cohorts for the campus' do
            ids = [@cohort1, @cohort4].map { |c| c.id.to_s }.sort
            expect(@campus_admin.default_cohort_ids_for_filter.sort).to eq ids
          end
        end

        describe 'cohort_admin' do
          it 'returns ids for all currently running administered cohorts' do
            ids = [@cohort1.id.to_s]
            expect(@cohort_admin.default_cohort_ids_for_filter).to eq ids
          end

          it 'returns ids for all currently running administered cohorts and own cohort if user is on cohort themselves' do
            ids = [@cohort1.id.to_s]
            expect(@user4.default_cohort_ids_for_filter).to eq ids
          end
        end

        describe 'user' do
          it 'returns own cohort' do
            expect(@user1.accessible_cohorts.map(&:id)).to eq [@user1.cohort.id]
          end
        end
      end

      describe 'with no running cohorts' do
        before :each do
          @cohort1.delete
        end

        describe 'admin' do
          it 'returns ids for all cohorts' do
            ids = [@cohort2, @cohort3].map { |c| c.id.to_s }.sort
            expect(@admin.default_cohort_ids_for_filter.sort).to eq ids
          end
        end

        describe 'campus_admin' do
          it 'returns ids for all accessible cohorts for the campus' do
            ids = [@cohort2.id.to_s]
            expect(@campus_admin.default_cohort_ids_for_filter.sort).to eq ids
          end
        end

        describe 'cohort_admin' do
          it 'returns ids for all administered cohorts' do
            ids = [@cohort3.id.to_s]
            expect(@cohort_admin.default_cohort_ids_for_filter).to eq ids
          end

          it 'returns ids for all administered cohorts and own cohort if user is on cohort themselves' do
            ids = [@cohort3.id.to_s]
            expect(@user4.default_cohort_ids_for_filter).to eq ids
          end
        end

        describe 'user' do
          it 'returns own cohort' do
            [@user2, @user3].each do |user|
              expect(user.accessible_cohorts.map(&:id)).to eq [user.cohort.id]
            end
          end
        end
      end
    end
  end

  private
  def flatten_hash_to_ids(hash)
    hash.reduce({}) { |m, (k, v)| m[k.id] = v.map(&:id).sort; m }
  end
end