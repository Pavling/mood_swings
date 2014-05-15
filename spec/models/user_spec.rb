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
    it "returns all students who are configured to receive email reminders" do
      user = FactoryGirl.create(:user)
      2.times { FactoryGirl.create(:user, skip_email_reminders: true) }

      expect(User.desiring_email_reminder).to eq [user]
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
        as = FactoryGirl.create(:answer_set, user: @user) 
        as.update_attribute(:created_at, ((i+1)*5).minutes.ago)
      end
      @answer_set = FactoryGirl.create(:answer_set, user: @user)
    end

    it 'returns the most recently created answer set for the user' do
      expect(@user.last_answer_set).to eq @answer_set
    end

    it 'returns the most recently created answer set for the user, even if other users have more recent answer sets' do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:answer_set, user: user)

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


  it '.needing_reminder_email'

  it '.mood_swung_today'

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
          expect(@user4.accessible_cohorts.map(&:id).sort).to eq ids
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


    end


  end


  it '#default_cohort_ids_for_filter'

  it '#accessible_campuses'

  it '#accessible_answer_sets'

  private
  def flatten_hash_to_ids(hash)
    return_hash = {}
    hash.each do |k, v|
      return_hash[k.id] = v.map(&:id).sort
    end
    return_hash
  end


end