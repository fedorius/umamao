class VotesController < ApplicationController
  before_filter :login_required
  before_filter :check_permissions, :except => [:index]

  def index
    redirect_to(root_path)
  end

  # TODO: refactor
  def create
    vote = Vote.new(:voteable_type => params[:voteable_type],
                    :voteable_id => params[:voteable_id],
                    :user => current_user)
    vote_type = ""
    if params[:vote_up] || params['vote_up.x'] || params['vote_up.y']
      vote_type = "vote_up"
      vote.value = 1
    elsif params[:vote_down] || params['vote_down.x'] || params['vote_down.y']
      vote_type = "vote_down"
      vote.value = -1
    end
    vote.group = vote.voteable.group

    vote_state = push_vote(vote)

    respond_to do |format|
      format.html{redirect_to params[:source]}

      format.js do
        if vote_state != :error
          average = vote.voteable.reload.votes_average
          render(:json => {:success => true,
                           :message => flash[:notice],
                           :vote_type => vote_type,
                           :vote_state => vote_state,
                           :average => average}.to_json)
        else
          render(:json => {:success => false, :message => flash[:error] }.to_json)
        end
      end

      format.json do
        if vote_state != :error
          average = vote.voteable.reload.votes_average
          render(:json => {:success => true,
                           :message => flash[:notice],
                           :vote_type => vote_type,
                           :vote_state => vote_state,
                           :average => average}.to_json)
        else
          render(:json => {:success => false, :message => flash[:error] }.to_json)
        end
      end
    end
  end

  def destroy
    @vote = Vote.find(params[:id])
    voteable = @vote.voteable
    value = @vote.value
    if  @vote && current_user == @vote.user
      @vote.destroy
      voteable.remove_vote!(value, current_user)
    end
    respond_to do |format|
      format.html { redirect_to params[:source] }
      format.json  { head :ok }
    end
  end

  protected
  def check_permissions
    unless logged_in?
      flash[:error] = t(:unauthenticated, :scope => "votes.create")
      respond_to do |format|
        format.html do
          flash[:error] += ", [#{t("global.please_login")}](#{new_user_session_path})"
          redirect_to params[:source]
        end
        format.json do
          flash[:error] = t("global.please_login")
          render(:json => {:status => :unauthenticate, :success => false, :message => flash[:error] }.to_json)
        end
        format.js do
          flash[:error] = t("global.please_login")
          render(:json => {:status => :unauthenticate, :success => false, :message => flash[:error] }.to_json)
        end
      end
    end
  end

  def push_vote(vote)
    user_vote = current_user.vote_on(vote.voteable)
    voteable = vote.voteable

    state = :error
    if user_vote.nil?
      if vote.save
        track_event("#{vote.value == 1 ? 'up' : 'down'}voted".to_sym,
                    :voteable => voteable.class.name.downcase)
        vote.voteable.add_vote!(vote.value, current_user)
        flash[:notice] = t("votes.create.flash_notice")
        state = :created
      else
        flash[:error] = vote.errors.full_messages.join(", ")
      end
    elsif(user_vote.valid?)
      if(user_vote.value != vote.value)
        voteable.remove_vote!(user_vote.value, current_user)
        voteable.add_vote!(vote.value, current_user)

        user_vote.value = vote.value
        user_vote.save
        if vote.value == 1
          track_event(:changed_downvote_to_upvote,
                      :voteable => voteable.class.name.downcase)
        else
          track_event(:changed_upvote_to_downvote,
                      :voteable => voteable.class.name.downcase)
        end
        flash[:notice] = t("votes.create.flash_notice")
        state = :updated
      else
        value = vote.value
        user_vote.destroy
        voteable.remove_vote!(value, current_user)
        track_event(:removed_vote, :voteable => voteable.class.name.downcase)

        flash[:notice] = t("votes.destroy.flash_notice")
        state = :deleted
      end
    else
      flash[:error] = user_vote.errors.full_messages.join(", ")
      state = :error
    end

    state
  end
end
