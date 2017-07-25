module CollectionsHelper
  def truncate_link(link)
    title = link.title ? link.title : 'undefined'
    markup = "<a target='_blank' class='ext' href='#{link.href}' title='#{link.title}'>#{title.truncate(64)}</a>"
    markup.html_safe
  end
end
