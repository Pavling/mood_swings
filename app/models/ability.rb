class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can :create, AnswerSet

    can :read, AnswerSet do |answer_set|
      answer_set.user == user
    end

    case
      when user.admin?
        can :manage, :all

        cannot :destroy, Campus do |campus|
          campus.cohorts.any?
        end 

      when user.cohort_admin? || user.campus_admin?
        if user.campus_admin?
          can :granularity_by_campus, AnswerSet
          can :manage, :cohort do |cohort|
            user.administered_cohorts.include?(cohort)
          end
        end

        can :invite, User if user.invitable_cohorts.any?

        can :granularity_by_cohort, AnswerSet

        can :read, Cohort do |cohort|
          user.accessible_cohorts.include?(cohort)
        end

    end
  end
end
