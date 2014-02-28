class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    else
      can :create, AnswerSet
      can :read, AnswerSet do |answer_set|
        answer_set.user == user
      end
    end
  end
end
