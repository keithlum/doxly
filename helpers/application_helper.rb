module ApplicationHelper

  def stylesheet_link_tag(url, options={})
    url = asset_manifest_url_for('stylesheet', url)

    super(url, options)
  end

  def javascript_include_tag(url, options={})
    url = asset_manifest_url_for('javascript', url)

    super(url, options)
  end

  def image_tag(url, options={})
    url = asset_manifest_url_for('asset', url)

    super(url, options)
  end

  def image_path(url, options={})
    url = asset_manifest_url_for('asset', url)

    super(url, options)
  end

  def image_url(url, options={})
    url = asset_manifest_url_for('asset', url)

    super((ActionController::Base.asset_host || "") + url, options)
  end

  private

  def asset_manifest_url_for(type, url)
    unless Rails.env == 'development'
      url = eval("AssetManifest.#{type}_path('#{url}').gsub('#{type == 'asset' ? 'image': type}s/', '')")
    end
    url
  end
end
