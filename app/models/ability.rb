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

      when user.cohort_admin?
        can :invite, User

        can :granularity_by_cohort, AnswerSet

        can :read, Cohort do |cohort|
          cohort.administrators.include?(user)
        end

    end
  end
end
