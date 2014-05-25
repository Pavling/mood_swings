class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can :create, AnswerSet if user.persisted?

    can :read, AnswerSet do |answer_set|
      answer_set.user == user
    end

    if user.admin?
      can :manage, :all
    else

      can :granularity_by_campus, AnswerSet if user.campus_admin?
      can :granularity_by_cohort, AnswerSet if user.cohort_admin? || user.campus_admin?
      can :granularity_by_person_metric, AnswerSet if user.cohort_admin? || user.campus_admin?

      can :manage, :campus do |campus|
        user.administered_campuses.include?(campus)
      end

      can :manage, :cohort do |cohort|
        user.administered_cohorts.include?(cohort)
      end

      can :create, Cohort if user.campus_admin?

      can :read, Cohort do |cohort|
        user.accessible_cohorts.include?(cohort)
      end

      can :invite, User if user.invitable_cohorts.any?

      can :manage, User do |target_user|
        user.accessible_users.include?(target_user)
      end

      cannot :alter_email, User

    end

    cannot :destroy, Answer

    cannot :destroy, AnswerSet

    cannot :destroy, Campus do |campus|
      campus.cohorts.any?
    end

    cannot :destroy, Cohort do |cohort|
      cohort.answer_sets.any?
    end

    cannot :destroy, Metric do |metric|
      metric.answers.any?
    end

    cannot :destroy, User do |target_user|
      target_user.answer_sets.any?
    end

  end
end
