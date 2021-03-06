class ArticlesController < ApplicationController
	before_action :authenticate_user!, only: [:new, :edit]
	before_action :set_article, except: [:index, :new, :create]
	before_action :authenticate_editor!, only: [:new, :create, :update]
	before_action :authenticate_admin!, only: [:destroy, :publish]
	
	def index
		@articles = Article.paginate(:page => params[:page], :per_page => 7).publicados
	end
	def show
		@comment = Comment.new
		@articles.update_visits_count	

		respond_to do |format|
			format.html
			format.pdf do
				pdf = ArticlePdf.new(@articles)
				send_data pdf.render, filename: "Articulo_#{@articles.title}.pdf",
										type: "application/pdf",
										disposition: "inline"
						#pdf = Prawn::Document.new(:page_size => [1000, 20000])
		#pdf = Prawn::Document.new(:page_size => '2A0')
		#pdf = Prawn::Document.new(:page_layout => :landscape)
			end
		end	
	end
	def new
		@articles = Article.new
	end
	def edit
		
	end
	def update
		   @articles.categories = params[:categories]
		   @articles.update_categories
		if @articles.update(article_params)		   
		redirect_to @articles
		else 
		render :edit
		end
	end
	def create
		@articles = current_user.articles.new(article_params)			
		@articles.categories = params[:categories]
		if @articles.save
    		redirect_to @articles
        else
        	render :new
       end		
	end
	def destroy
		
	    @articles.destroy
	    redirect_to articles_path
	end

	def publish
		@articles.publish!
		redirect_to @articles
	end
	
	def draft
		@articles.unpublish!
		redirect_to @articles
	end

	private 
	def set_article
		@articles = Article.find(params[:id])
	end
	def article_params
       params.require(:article).permit(:title, :body, :avatars, :categories)
    end

end