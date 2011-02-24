class UniversitiesController < ApplicationController
  #before_filter :login_required

  def index
    set_page_title(t("universities.index.title"))
    options = {:per_page => 30, :page => params[:page] || 1, :banned => false}
    @universities = University.all.paginate(options)

    respond_to do |format|
      format.html
    end
  end

  def new
    @university = University.new
    render 'new', :layout => 'welcome'
  end

  def create
  end

  def show
    @university = University.find_by_id(params[:id])

    respond_to do |format|
      format.html
    end
  end

end


