class SchedulerController < ApplicationController
  before_action :authenticate_user!
  # jump date needs to be set before set_scheduled_meetings,
  # so that the correct time can be used in the course instance query
  #
  # The jump date should also be set for JS requests, so that the
  # source for the autocomplete can be set to the right date.
  before_action :set_search_date, only: [:index], :if => [:semester_request?, :xhr_request?]
  before_action :set_scheduled_meetings, only: [:index], :if => :xhr_request?
  before_action :set_enrollment, only: [:create]

  # GET /scheduler
  # GET /scheduler.json
  def index
  end

  # POST /scheduler.json
  def create
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_enrollment
    @enrollment = Enrollment.where(user: current_user, course_instance_id: params[:course_instance_id]).first_or_create
  end

  # Set the course instances to be rendered in the schedule
  # This is for the JSON feed that fullcalendar requires
  def set_scheduled_meetings
    # timecop should be set here to get the correct enrollments in the query
    @scheduled_meetings = current_user.enrolled_courses.ongoing(@search_date || Date.today).includes(:meetings, :course).flat_map(&:meetings).flat_map(&:scheduled_meetings)
  end

  def semester_request?
    params.include? :semester
  end
end
