class DocController < ApplicationController
  def privacy
    set_page_title(t("doc.privacy.title"))
  end
  def tos
    set_page_title(t("doc.tos.title"))
  end
end
