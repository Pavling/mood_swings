require 'spec_helper'
require "cancan/matchers"

describe User do
  describe "abilities" do
    let(:ability) { Ability.new(user) }
    let(:user) { nil }

    before :all do
      setup_dummy_data
    end

    after :all do
      DatabaseCleaner.clean_with(:truncation)
    end
    
    context "when is an admin" do
      let(:user) { @admin_user }

      context 'Answer' do
        describe 'read' do
          it "should be able to read any answer" do
            Answer.all.each do |answer|
              expect(ability).to be_able_to(:read, answer)
            end
          end
        end

        describe 'create' do
          it "should be able to create answer" do
            expect(ability).to be_able_to(:create, Answer)
          end
        end

        describe 'update' do
          it "should be able to update any answer" do
            Answer.all.each do |answer|
              expect(ability).to be_able_to(:update, answer)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:destroy, answer)
            end
          end
        end
      end

      context 'AnswerSet' do
        describe 'read' do
          it "should be able to read any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to be_able_to(:read, answer_set)
            end
          end
        end

        describe 'create' do
          it "should be able to create answer_set" do
            expect(ability).to be_able_to(:create, AnswerSet)
          end
        end

        describe 'update' do
          it "should be able to update any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to be_able_to(:update, answer_set)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:destroy, answer_set)
            end
          end
        end

        describe 'granularity' do
          it 'should have granularity by campus' do
            expect(ability).to be_able_to(:granularity_by_campus, AnswerSet)
          end

          it 'should have granularity by campus' do
            expect(ability).to be_able_to(:granularity_by_cohort, AnswerSet)
          end

          it 'should have granularity by campus' do
            expect(ability).to be_able_to(:granularity_by_person_metric, AnswerSet)
          end
        end
      end

      context 'Campus' do
        describe 'read' do
          it "should be able to read any campus" do
            Campus.all.each do |campus|
              expect(ability).to be_able_to(:read, campus)
            end
          end
        end

        describe 'create' do
          it "should be able to create campus" do
            expect(ability).to be_able_to(:create, Campus)
          end
        end

        describe 'update' do
          it "should be able to update any campus" do
            Campus.all.each do |campus|
              expect(ability).to be_able_to(:update, campus)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any campus with cohorts" do
            [@campus1, @campus2].each do |campus|
              expect(ability).to_not be_able_to(:destroy, campus)
            end
          end

          it "should be able to destroy any campus without cohorts" do
            expect(ability).to be_able_to(:destroy, @campus3)
          end
        end
      end

      context 'Cohort' do
        describe 'read' do
          it "should be able to read any cohort" do
            Cohort.all.each do |cohort|
              expect(ability).to be_able_to(:read, cohort)
            end
          end
        end

        describe 'create' do
          it "should be able to create cohort" do
            expect(ability).to be_able_to(:create, Cohort)
          end
        end

        describe 'update' do
          it "should be able to update any cohort" do
            Cohort.all.each do |cohort|
              expect(ability).to be_able_to(:update, cohort)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any cohort with answer_sets" do
            [@cohort1, @cohort2, @cohort3, @cohort4].each do |cohort|
              expect(ability).to_not be_able_to(:destroy, cohort)
            end
          end

          it "should be able to destroy any cohort without answer_sets" do
            expect(ability).to be_able_to(:destroy, @cohort5)
          end
        end
      end

      context 'Metric' do
        describe 'destroy' do
          it "should be able to read any metric" do
            Metric.all.each do |metric|
              expect(ability).to be_able_to(:read, metric)
            end
          end
        end

        describe 'create' do
          it "should be able to create metric" do
            expect(ability).to be_able_to(:create, Metric)
          end
        end

        describe 'update' do
          it "should be able to update any metric" do
            Metric.all.each do |metric|
              expect(ability).to be_able_to(:update, metric)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any metric with answers" do
            @metrics.each do |metric|
              expect(ability).to_not be_able_to(:destroy, metric)
            end
          end

          it "should be able to destroy any metric without answers" do
            expect(ability).to be_able_to(:destroy, @metric6)
          end
        end
      end

      context 'User' do
        describe 'alter_email' do
          it "should be able to alter_email of any user" do
            User.all.each do |user|
              expect(ability).to be_able_to(:alter_email, user)
            end
          end
        end

        describe 'read' do
          it "should be able to read any user" do
            User.all.each do |user|
              expect(ability).to be_able_to(:read, user)
            end
          end
        end

        describe 'create' do
          it "should be able to create user" do
            expect(ability).to be_able_to(:create, User)
          end
        end

        describe 'update' do
          it "should be able to update any user" do
            User.all.each do |user|
              expect(ability).to be_able_to(:update, user)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any user with answer_sets" do
            [@user1, @user2, @user3, @user4, @user5].each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end

          it "should be able to destroy any user without answer_sets" do
            expect(ability).to be_able_to(:destroy, @user6)
          end
        end
      end
    end



    context "when is a campus_admin" do
      let(:user) { @campus_admin }

      context 'Answer' do
        describe 'read' do
          it "should not be able to read any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:read, answer)
            end
          end
        end

        describe 'create' do
          it "should not be able to create answer" do
            expect(ability).to_not be_able_to(:create, Answer)
          end
        end

        describe 'update' do
          it "should not be able to update any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:update, answer)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:destroy, answer)
            end
          end
        end
      end

      context 'AnswerSet' do
        describe 'read' do
          it "should not be able to read any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:read, answer_set)
            end
          end
        end

        describe 'create' do
          it "should be able to create answer_set" do
            expect(ability).to be_able_to(:create, AnswerSet)
          end
        end

        describe 'update' do
          it "should not be able to update any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:update, answer_set)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:destroy, answer_set)
            end
          end
        end

        describe 'granularity' do
          it 'should have granularity by campus' do
            expect(ability).to be_able_to(:granularity_by_campus, AnswerSet)
          end

          it 'should have granularity by cohort' do
            expect(ability).to be_able_to(:granularity_by_cohort, AnswerSet)
          end

          it 'should have granularity by campus' do
            expect(ability).to be_able_to(:granularity_by_person_metric, AnswerSet)
          end
        end
      end

      context 'Campus' do
        let(:administered_campuses) { [@campus1, @campus4] }
        let(:non_administered_campuses) { [@campus2, @campus3] }

        describe 'read' do
          it "should be able to read any administered campus" do
            administered_campuses.each do |campus|
              expect(ability).to be_able_to(:read, campus)
            end
          end

          it "should not be able to read any non-administered campus" do
            non_administered_campuses.each do |campus|
              expect(ability).to_not be_able_to(:read, campus)
            end
          end
        end

        describe 'create' do
          it "should not be able to create campus" do
            expect(ability).to_not be_able_to(:create, Campus)
          end
        end

        describe 'update' do
          it "should be able to update any administered campus" do
            administered_campuses.each do |campus|
              expect(ability).to be_able_to(:update, campus)
            end
          end

          it "should not be able to update any non-administered campus" do
            non_administered_campuses.each do |campus|
              expect(ability).to_not be_able_to(:update, campus)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any administered campus with cohorts" do
            expect(ability).to_not be_able_to(:destroy, @campus1)
          end

          it "should not be able to destroy any non-administered campus with cohorts" do
            [@campus2, @campus3].each do |campus|
              expect(ability).to_not be_able_to(:destroy, campus)
            end
          end

          it "should be able to destroy any administered campus without cohorts" do
            expect(ability).to be_able_to(:destroy, @campus4)
          end

          it "should not be able to destroy any non-administered campus without cohorts" do
            expect(ability).to_not be_able_to(:destroy, @campus5)
          end
        end
      end

      context 'Cohort' do
        let(:cohorts_in_administered_campuses) { [@cohort1, @cohort2, @cohort5] }
        let(:cohorts_not_in_administered_campuses) { [@cohort3, @cohort4, @cohort6] }

        describe 'read' do
          it "should be able to read any cohort in administered campuses" do
            cohorts_in_administered_campuses.each do |cohort|
              expect(ability).to be_able_to(:read, cohort)
            end
          end

          it "should not be able to read any cohort in non-administered campuses" do
            cohorts_not_in_administered_campuses.each do |cohort|
              expect(ability).to_not be_able_to(:read, cohort)
            end
          end
        end

        describe 'create' do
          it "should be able to create cohort" do
            expect(ability).to be_able_to(:create, Cohort)
          end
        end

        describe 'update' do
          it "should be able to update any cohort in administered campuses" do
            cohorts_in_administered_campuses.each do |cohort|
              expect(ability).to be_able_to(:update, cohort)
            end
          end

          it "should not be able to update any cohort in non-administered campuses" do
            cohorts_not_in_administered_campuses.each do |cohort|
              expect(ability).to_not be_able_to(:update, cohort)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any cohort with answer_sets" do
            cohorts = (cohorts_in_administered_campuses + cohorts_not_in_administered_campuses).select{|c|c.answer_sets.any?}

            cohorts.each do |cohort|
              expect(ability).to_not be_able_to(:destroy, cohort)
            end
          end

          it "should be able to destroy any cohort in administered campuses without answer_sets" do
            cohorts_in_administered_campuses.select{|c|c.answer_sets.blank?}.each do |cohort|
              expect(ability).to be_able_to(:destroy, cohort)
            end
          end

          it "should not be able to destroy any cohort in non-administered campuses without answer_sets" do
            cohorts_not_in_administered_campuses.select{|c|c.answer_sets.blank?}.each do |cohort|
              expect(ability).to_not be_able_to(:destroy, cohort)
            end
          end

        end
      end

      context 'Metric' do
        describe 'destroy' do
          it "should not be able to read any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:read, metric)
            end
          end
        end

        describe 'create' do
          it "should not be able to create metric" do
            expect(ability).to_not be_able_to(:create, Metric)
          end
        end

        describe 'update' do
          it "should not be able to update any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:update, metric)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:destroy, metric)
            end
          end
        end
      end

      context 'User' do
        let(:users_in_accessible_cohorts) { [@user1, @user2, @user4, @user6] }
        let(:users_not_in_accessible_cohorts) { [@user3, @user5, @user7, @admin_user, @campus_admin, @cohort_admin] }

        describe 'alter_email' do
          it "should not be able to alter_email of any user" do
            User.all.each do |user|
              expect(ability).to_not be_able_to(:alter_email, user)
            end
          end
        end

        describe 'read' do
          it "should be able to read any user in accessible cohorts" do
            users_in_accessible_cohorts.each do |user|
              expect(ability).to be_able_to(:read, user)
            end
          end

          it "should not be able to read any user in non-accessible cohorts" do
            users_not_in_accessible_cohorts.each do |user|
              expect(ability).to_not be_able_to(:read, user)
            end
          end
        end

        describe 'create' do
          it "should be able to create user" do
            expect(ability).to be_able_to(:create, User)
          end
        end

        describe 'update' do
          it "should be able to update any user in accessible cohorts" do
            users_in_accessible_cohorts.each do |user|
              expect(ability).to be_able_to(:update, user)
            end
          end

          it "should not be able to update any user in non-accessible users" do
            users_not_in_accessible_cohorts.each do |user|
              expect(ability).to_not be_able_to(:update, user)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any accessible user with answer_sets" do
            users = users_in_accessible_cohorts.select{|u|u.answer_sets.any?}
            users.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end

          it "should not be able to destroy any non-accessible user with answer_sets" do
            users = users_not_in_accessible_cohorts.select{|u|u.answer_sets.any?}
            users.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end

          it "should be able to destroy any accessible user without answer_sets" do
            users = users_in_accessible_cohorts.select{|u|u.answer_sets.blank?}
            users.each do |user|
              expect(ability).to be_able_to(:destroy, user)
            end
          end

          it "should not be able to destroy any non-accessible user without answer_sets" do
            users = users_not_in_accessible_cohorts.select{|u|u.answer_sets.blank?}
            users.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end
        end
      end
    end



    context "when is a cohort_admin" do
      let(:user) { @cohort_admin }

      context 'Answer' do
        describe 'read' do
          it "should not be able to read any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:read, answer)
            end
          end
        end

        describe 'create' do
          it "should not be able to create answer" do
            expect(ability).to_not be_able_to(:create, Answer)
          end
        end

        describe 'update' do
          it "should not be able to update any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:update, answer)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:destroy, answer)
            end
          end
        end
      end

      context 'AnswerSet' do
        describe 'read' do
          it "should not be able to read any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:read, answer_set)
            end
          end
        end

        describe 'create' do
          it "should be able to create answer_set" do
            expect(ability).to be_able_to(:create, AnswerSet)
          end
        end

        describe 'update' do
          it "should not be able to update any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:update, answer_set)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:destroy, answer_set)
            end
          end
        end

        describe 'granularity' do
          it 'should not have granularity by campus' do
            expect(ability).to_not be_able_to(:granularity_by_campus, AnswerSet)
          end

          it 'should have granularity by cohort' do
            expect(ability).to be_able_to(:granularity_by_cohort, AnswerSet)
          end

          it 'should have granularity by campus' do
            expect(ability).to be_able_to(:granularity_by_person_metric, AnswerSet)
          end
        end
      end

      context 'Campus' do
        describe 'read' do
          it "should not be able to read any campus" do
            Campus.all.each do |campus|
              expect(ability).to_not be_able_to(:read, campus)
            end
          end
        end

        describe 'create' do
          it "should not be able to create campus" do
            expect(ability).to_not be_able_to(:create, Campus)
          end
        end

        describe 'update' do
          it "should not be able to update any campus" do
            Campus.all.each do |campus|
              expect(ability).to_not be_able_to(:update, campus)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any campus" do
            Campus.all.each do |campus|
              expect(ability).to_not be_able_to(:destroy, campus)
            end
          end
        end
      end

      context 'Cohort' do
        let(:administered_cohorts) { [@cohort1, @cohort3] }
        let(:non_administered_cohorts) { [@cohort2, @cohort4, @cohort5, @cohort6] }

        describe 'read' do
          it "should be able to read any administered cohort" do
            administered_cohorts.each do |cohort|
              expect(ability).to be_able_to(:read, cohort)
            end
          end

          it "should not be able to read any non-administered cohort" do
            non_administered_cohorts.each do |cohort|
              expect(ability).to_not be_able_to(:read, cohort)
            end
          end
        end

        describe 'create' do
          it "should not be able to create cohort" do
            expect(ability).to_not be_able_to(:create, Cohort)
          end
        end

        describe 'update' do
          it "should be able to update any administered cohort" do
            administered_cohorts.each do |cohort|
              expect(ability).to be_able_to(:update, cohort)
            end
          end

          it "should not be able to update any non-administered cohort" do
            non_administered_cohorts.each do |cohort|
              expect(ability).to_not be_able_to(:update, cohort)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any cohort with answer_sets" do
            cohorts = (administered_cohorts + non_administered_cohorts).select{|c|c.answer_sets.any?}

            cohorts.each do |cohort|
              expect(ability).to_not be_able_to(:destroy, cohort)
            end
          end

          it "should be able to destroy any administered cohort without answer_sets" do
            administered_cohorts.select{|c|c.answer_sets.blank?}.each do |cohort|
              expect(ability).to be_able_to(:destroy, cohort)
            end
          end

          it "should not be able to destroy any non-administered cohort without answer_sets" do
            non_administered_cohorts.select{|c|c.answer_sets.blank?}.each do |cohort|
              expect(ability).to_not be_able_to(:destroy, cohort)
            end
          end

        end
      end

      context 'Metric' do
        describe 'destroy' do
          it "should not be able to read any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:read, metric)
            end
          end
        end

        describe 'create' do
          it "should not be able to create metric" do
            expect(ability).to_not be_able_to(:create, Metric)
          end
        end

        describe 'update' do
          it "should not be able to update any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:update, metric)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:destroy, metric)
            end
          end
        end
      end

      context 'User' do
        let(:users_in_accessible_cohorts) { [@user1, @user3, @user4] }
        let(:users_not_in_accessible_cohorts) { [@user2, @user5, @user6, @user7, @admin_user, @campus_admin, @cohort_admin] }

        describe 'alter_email' do
          it "should not be able to alter_email of any user" do
            User.all.each do |user|
              expect(ability).to_not be_able_to(:alter_email, user)
            end
          end
        end

        describe 'read' do
          it "should be able to read any user in accessible cohorts" do
            users_in_accessible_cohorts.each do |user|
              expect(ability).to be_able_to(:read, user)
            end
          end

          it "should not be able to read any user in non-accessible cohorts" do
            users_not_in_accessible_cohorts.each do |user|
              expect(ability).to_not be_able_to(:read, user)
            end
          end
        end

        describe 'create' do
          it "should be able to create user" do
            expect(ability).to be_able_to(:create, User)
          end
        end

        describe 'update' do
          it "should be able to update any user in accessible cohorts" do
            users_in_accessible_cohorts.each do |user|
              expect(ability).to be_able_to(:update, user)
            end
          end

          it "should not be able to update any user in non-accessible users" do
            users_not_in_accessible_cohorts.each do |user|
              expect(ability).to_not be_able_to(:update, user)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any accessible user with answer_sets" do
            users = users_in_accessible_cohorts.select{|u|u.answer_sets.any?}
            users.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end

          it "should not be able to destroy any non-accessible user with answer_sets" do
            users = users_not_in_accessible_cohorts.select{|u|u.answer_sets.any?}
            users.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end

          it "should be able to destroy any accessible user without answer_sets" do
            users = users_in_accessible_cohorts.select{|u|u.answer_sets.blank?}
            users.each do |user|
              expect(ability).to be_able_to(:destroy, user)
            end
          end

          it "should not be able to destroy any non-accessible user without answer_sets" do
            users = users_not_in_accessible_cohorts.select{|u|u.answer_sets.blank?}
            users.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end
        end
      end
    end




    context "when is a user who is a cohort_admin" do
      let(:user) { @user4 }

      context 'Answer' do
        describe 'read' do
          it "should not be able to read any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:read, answer)
            end
          end
        end

        describe 'create' do
          it "should not be able to create answer" do
            expect(ability).to_not be_able_to(:create, Answer)
          end
        end

        describe 'update' do
          it "should not be able to update any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:update, answer)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:destroy, answer)
            end
          end
        end
      end

      context 'AnswerSet' do
        describe 'read' do
          it "should not be able to read any answer_set created by other users" do
            answer_sets = AnswerSet.all.reject { |as| as.user == user }

            answer_sets.each do |answer_set|
              expect(ability).to_not be_able_to(:read, answer_set)
            end
          end

          it "should be able to read any answer_set created by self" do
            answer_sets = AnswerSet.all.select { |as| as.user == user }

            answer_sets.each do |answer_set|
              expect(ability).to be_able_to(:read, answer_set)
            end
          end
        end

        describe 'create' do
          it "should be able to create answer_set" do
            expect(ability).to be_able_to(:create, AnswerSet)
          end
        end

        describe 'update' do
          it "should not be able to update any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:update, answer_set)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:destroy, answer_set)
            end
          end
        end

        describe 'granularity' do
          it 'should not have granularity by campus' do
            expect(ability).to_not be_able_to(:granularity_by_campus, AnswerSet)
          end

          it 'should have granularity by cohort' do
            expect(ability).to be_able_to(:granularity_by_cohort, AnswerSet)
          end

          it 'should have granularity by campus' do
            expect(ability).to be_able_to(:granularity_by_person_metric, AnswerSet)
          end
        end
      end

      context 'Campus' do
        describe 'read' do
          it "should not be able to read any campus" do
            Campus.all.each do |campus|
              expect(ability).to_not be_able_to(:read, campus)
            end
          end
        end

        describe 'create' do
          it "should not be able to create campus" do
            expect(ability).to_not be_able_to(:create, Campus)
          end
        end

        describe 'update' do
          it "should not be able to update any campus" do
            Campus.all.each do |campus|
              expect(ability).to_not be_able_to(:update, campus)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any campus" do
            Campus.all.each do |campus|
              expect(ability).to_not be_able_to(:destroy, campus)
            end
          end
        end
      end

      context 'Cohort' do
        let(:administered_cohorts) { [@cohort3] }
        let(:non_administered_cohorts) { [@cohort1, @cohort2, @cohort4, @cohort5, @cohort6] }

        describe 'read' do
          it "should be able to read any administered cohort" do
            administered_cohorts.each do |cohort|
              expect(ability).to be_able_to(:read, cohort)
            end
          end

          it "should not be able to read any non-administered cohort" do
            (non_administered_cohorts - [@cohort1]).each do |cohort|
              expect(ability).to_not be_able_to(:read, cohort)
            end
          end
        end

        describe 'create' do
          it "should not be able to create cohort" do
            expect(ability).to_not be_able_to(:create, Cohort)
          end
        end

        describe 'update' do
          it "should be able to update any administered cohort" do
            administered_cohorts.each do |cohort|
              expect(ability).to be_able_to(:update, cohort)
            end
          end

          it "should not be able to update any non-administered cohort" do
            non_administered_cohorts.each do |cohort|
              expect(ability).to_not be_able_to(:update, cohort)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any cohort with answer_sets" do
            cohorts = (administered_cohorts + non_administered_cohorts).select{|c|c.answer_sets.any?}

            cohorts.each do |cohort|
              expect(ability).to_not be_able_to(:destroy, cohort)
            end
          end

          it "should be able to destroy any administered cohort without answer_sets" do
            administered_cohorts.select{|c|c.answer_sets.blank?}.each do |cohort|
              expect(ability).to be_able_to(:destroy, cohort)
            end
          end

          it "should not be able to destroy any non-administered cohort without answer_sets" do
            non_administered_cohorts.select{|c|c.answer_sets.blank?}.each do |cohort|
              expect(ability).to_not be_able_to(:destroy, cohort)
            end
          end

        end
      end

      context 'Metric' do
        describe 'destroy' do
          it "should not be able to read any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:read, metric)
            end
          end
        end

        describe 'create' do
          it "should not be able to create metric" do
            expect(ability).to_not be_able_to(:create, Metric)
          end
        end

        describe 'update' do
          it "should not be able to update any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:update, metric)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:destroy, metric)
            end
          end
        end
      end

      context 'User' do
        let(:users_in_accessible_cohorts) { [@user3] }
        let(:users_not_in_accessible_cohorts) { [@user1, @user2, @user4, @user5, @user6, @user7, @admin_user, @campus_admin, @cohort_admin] }

        describe 'alter_email' do
          it "should not be able to alter_email of any user" do
            User.all.each do |user|
              expect(ability).to_not be_able_to(:alter_email, user)
            end
          end
        end

        describe 'read' do
          it "should be able to read any user in accessible cohorts" do
            users_in_accessible_cohorts.each do |user|
              expect(ability).to be_able_to(:read, user)
            end
          end

          it "should not be able to read any user in non-accessible cohorts" do
            users_not_in_accessible_cohorts.each do |user|
              expect(ability).to_not be_able_to(:read, user)
            end
          end
        end

        describe 'create' do
          it "should be able to create user" do
            expect(ability).to be_able_to(:create, User)
          end
        end

        describe 'update' do
          it "should be able to update any user in accessible cohorts" do
            users_in_accessible_cohorts.each do |user|
              expect(ability).to be_able_to(:update, user)
            end
          end

          it "should not be able to update any user in non-accessible users" do
            users_not_in_accessible_cohorts.each do |user|
              expect(ability).to_not be_able_to(:update, user)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any accessible user with answer_sets" do
            users = users_in_accessible_cohorts.select{|u|u.answer_sets.any?}
            users.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end

          it "should not be able to destroy any non-accessible user with answer_sets" do
            users = users_not_in_accessible_cohorts.select{|u|u.answer_sets.any?}
            users.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end

          it "should be able to destroy any accessible user without answer_sets" do
            users = users_in_accessible_cohorts.select{|u|u.answer_sets.blank?}
            users.each do |user|
              expect(ability).to be_able_to(:destroy, user)
            end
          end

          it "should not be able to destroy any non-accessible user without answer_sets" do
            users = users_not_in_accessible_cohorts.select{|u|u.answer_sets.blank?}
            users.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end
        end
      end
    end



    context "when is a user" do
      let(:user) { @user1 }

      context 'Answer' do
        describe 'read' do
          it "should not be able to read any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:read, answer)
            end
          end
        end

        describe 'create' do
          it "should not be able to create answer" do
            expect(ability).to_not be_able_to(:create, Answer)
          end
        end

        describe 'update' do
          it "should not be able to update any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:update, answer)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer" do
            Answer.all.each do |answer|
              expect(ability).to_not be_able_to(:destroy, answer)
            end
          end
        end
      end

      context 'AnswerSet' do
        describe 'read' do
          it "should not be able to read any answer_set created by other users" do
            answer_sets = AnswerSet.all.reject { |as| as.user == user }

            answer_sets.each do |answer_set|
              expect(ability).to_not be_able_to(:read, answer_set)
            end
          end

          it "should be able to read any answer_set created by self" do
            answer_sets = AnswerSet.all.select { |as| as.user == user }

            answer_sets.each do |answer_set|
              expect(ability).to be_able_to(:read, answer_set)
            end
          end
        end

        describe 'create' do
          it "should be able to create answer_set" do
            expect(ability).to be_able_to(:create, AnswerSet)
          end
        end

        describe 'update' do
          it "should not be able to update any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:update, answer_set)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any answer_set" do
            AnswerSet.all.each do |answer_set|
              expect(ability).to_not be_able_to(:destroy, answer_set)
            end
          end
        end

        describe 'granularity' do
          it 'should not have granularity by campus' do
            expect(ability).to_not be_able_to(:granularity_by_campus, AnswerSet)
          end

          it 'should not have granularity by cohort' do
            expect(ability).to_not be_able_to(:granularity_by_cohort, AnswerSet)
          end

          it 'should not have granularity by campus' do
            expect(ability).to_not be_able_to(:granularity_by_person_metric, AnswerSet)
          end
        end
      end

      context 'Campus' do
        describe 'read' do
          it "should not be able to read any campus" do
            Campus.all.each do |campus|
              expect(ability).to_not be_able_to(:read, campus)
            end
          end
        end

        describe 'create' do
          it "should not be able to create campus" do
            expect(ability).to_not be_able_to(:create, Campus)
          end
        end

        describe 'update' do
          it "should not be able to update any campus" do
            Campus.all.each do |campus|
              expect(ability).to_not be_able_to(:update, campus)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any campus" do
            Campus.all.each do |campus|
              expect(ability).to_not be_able_to(:destroy, campus)
            end
          end
        end
      end

      context 'Cohort' do
        let(:enrolled_cohorts) { [@cohort1] }
        let(:non_enrolled_cohorts) { [@cohort2, @cohort3, @cohort4, @cohort5, @cohort6] }

        describe 'read' do
          it "should be able to read any enrolled cohort" do
            enrolled_cohorts.each do |cohort|
              expect(ability).to be_able_to(:read, cohort)
            end
          end

          it "should not be able to read any non-enrolled cohort" do
            (non_enrolled_cohorts - [@cohort1]).each do |cohort|
              expect(ability).to_not be_able_to(:read, cohort)
            end
          end
        end

        describe 'create' do
          it "should not be able to create cohort" do
            expect(ability).to_not be_able_to(:create, Cohort)
          end
        end

        describe 'update' do
          it "should not be able to update any enrolled cohort" do
            enrolled_cohorts.each do |cohort|
              expect(ability).to_not be_able_to(:update, cohort)
            end
          end

          it "should not be able to update any non-enrolled cohort" do
            non_enrolled_cohorts.each do |cohort|
              expect(ability).to_not be_able_to(:update, cohort)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any cohort with answer_sets" do
            cohorts = (enrolled_cohorts + non_enrolled_cohorts).select{|c|c.answer_sets.any?}

            cohorts.each do |cohort|
              expect(ability).to_not be_able_to(:destroy, cohort)
            end
          end

          it "should be able to destroy any enrolled cohort without answer_sets" do
            enrolled_cohorts.select{|c|c.answer_sets.blank?}.each do |cohort|
              expect(ability).to be_able_to(:destroy, cohort)
            end
          end

          it "should not be able to destroy any non-enrolled cohort without answer_sets" do
            non_enrolled_cohorts.select{|c|c.answer_sets.blank?}.each do |cohort|
              expect(ability).to_not be_able_to(:destroy, cohort)
            end
          end

        end
      end

      context 'Metric' do
        describe 'destroy' do
          it "should not be able to read any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:read, metric)
            end
          end
        end

        describe 'create' do
          it "should not be able to create metric" do
            expect(ability).to_not be_able_to(:create, Metric)
          end
        end

        describe 'update' do
          it "should not be able to update any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:update, metric)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any metric" do
            Metric.all.each do |metric|
              expect(ability).to_not be_able_to(:destroy, metric)
            end
          end
        end
      end

      context 'User' do
        describe 'alter_email' do
          it "should not be able to alter_email of any user" do
            User.all.each do |user|
              expect(ability).to_not be_able_to(:alter_email, user)
            end
          end
        end

        describe 'read' do
          it "should not be able to read any user" do
            User.all.each do |user|
              expect(ability).to_not be_able_to(:read, user)
            end
          end
        end

        describe 'create' do
          it "should be able to create user" do
            expect(ability).to be_able_to(:create, User)
          end
        end

        describe 'update' do
          it "should not be able to update any user" do
            User.all.each do |user|
              expect(ability).to_not be_able_to(:update, user)
            end
          end
        end

        describe 'destroy' do
          it "should not be able to destroy any user" do
            User.all.each do |user|
              expect(ability).to_not be_able_to(:destroy, user)
            end
          end
        end
      end
    end


  end


  def setup_dummy_data
    @start_of_week = Time.zone.now.beginning_of_week

    @metrics = 5.times.map { |i| FactoryGirl.create(:metric, measure: "metric#{i+1}") }
    @metric6 = FactoryGirl.create(:metric, measure: "metric6")

    @campus1 = FactoryGirl.create(:campus, name: :campus1)
    @campus2 = FactoryGirl.create(:campus, name: :campus2)
    @campus3 = FactoryGirl.create(:campus, name: :campus3)
    @campus4 = FactoryGirl.create(:campus, name: :campus4)
    @campus5 = FactoryGirl.create(:campus, name: :campus5)

    @cohort1 = FactoryGirl.create(:cohort, campus: @campus1, start_on: 60.days.ago.to_date, name: :cohort1)
    @cohort2 = FactoryGirl.create(:past_cohort, campus: @campus1, start_on: 60.days.ago.to_date, name: :cohort2)
    @cohort3 = FactoryGirl.create(:cohort, campus: @campus2, start_on: 60.days.ago.to_date, name: :cohort3)
    @cohort4 = FactoryGirl.create(:past_cohort, campus: @campus2, start_on: 60.days.ago.to_date, name: :cohort4)
    @cohort5 = FactoryGirl.create(:cohort, campus: @campus1, start_on: 60.days.ago.to_date, name: :cohort5)
    @cohort6 = FactoryGirl.create(:cohort, campus: @campus2, start_on: 60.days.ago.to_date, name: :cohort6)

    @admin_user = FactoryGirl.create(:admin_user)

    @campus_admin = FactoryGirl.create(:user, cohort: nil)
    @campus_admin.administered_campuses << @campus1
    @campus_admin.administered_campuses << @campus4

    @user1 = FactoryGirl.create(:user, cohort: @cohort1, name: :user1, email: 'user1@test.com')
    @user2 = FactoryGirl.create(:user, cohort: @cohort2, name: :user2, email: 'user2@test.com')
    @user3 = FactoryGirl.create(:user, cohort: @cohort3, name: :user3, email: 'user3@test.com')
    @user4 = FactoryGirl.create(:user, cohort: @cohort1, name: :user4, email: 'user4@test.com')
    @user5 = FactoryGirl.create(:user, cohort: @cohort4, name: :user5, email: 'user5@test.com')
    @user6 = FactoryGirl.create(:user, cohort: @cohort5, name: :user6, email: 'user6@test.com')
    @user7 = FactoryGirl.create(:user, cohort: @cohort4, name: :user7, email: 'user7@test.com')

    @cohort_admin = FactoryGirl.create(:user, cohort: nil)
    @cohort_admin.administered_cohorts << @cohort1
    @cohort_admin.administered_cohorts << @cohort3
    @user4.administered_cohorts << @cohort3

    @answer_sets = []
    second_count = 60

    @date1, @date2, @date3, @date4 = [0,7,14,21]
    [@date1, @date2, @date3, @date4].each_with_index do |day, i|
      second_count -= 1

      [@user1, @user2, @user3, @user4, @user5].each do |user|
        answer_set = FactoryGirl.build(:answer_set, user: user, cohort: user.cohort)
        @metrics.each_with_index do |m, j|
          value = [1,2,3,4][j%4]
          answer_set.answers << (answer = FactoryGirl.build(:answer_with_comments, answer_set: answer_set, metric: m, value: value))
          answer.update_attribute(:created_at, @start_of_week.ago(day.days).to_date.ago(second_count.seconds))
        end
        answer_set.update_attribute(:created_at, @start_of_week.ago(day.days).to_date.ago(second_count.seconds))

        @answer_sets << answer_set
      end
    end
  end


end