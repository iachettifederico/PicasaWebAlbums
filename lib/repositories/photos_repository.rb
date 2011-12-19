require_relative '../domain/photo'

module PhotosRepository
  def get_photos_by_album_id(id)
    xml = get_xml("http://picasaweb.google.com/data/feed/base/user/#{@email}/albumid/#{id}")
    photos = []
    xml.root.elements.each("//entry") do |entry|
      photo = PicasaWebAlbums::Photo.new
      photo.id = get_photo_id_from_photo_id_url(entry.elements["id"].text)
      photo.url = entry.elements["media:group/media:content"].attributes["url"]
      photo.width = entry.elements["media:group/media:content"].attributes["width"].to_i
      photo.height = entry.elements["media:group/media:content"].attributes["height"].to_i
      photo.caption = entry.elements["media:group/media:description"].text
      photo.file_name = entry.elements["media:group/media:title"].text
      photos << photo
    end
    return photos
  end

  def get_photo_by_album_id_and_photo_id(album_id, photo_id)
    photos = get_photos_by_album_id(album_id)
    photo_to_return = PicasaWebAlbums::Photo.new
    photos.each do |photo|
      if photo.id == photo_id
        photo_to_return = photo
      end
    end
    return photo_to_return
  end
  
  def get_photos_by_tags(tags)
    url = "http://picasaweb.google.com/data/feed/api/user/#{@email}?kind=photo&tag=#{get_tags_string(tags)}"
    xml = get_xml(url)
    photos = []
    xml.root.elements.each("//entry") do |entry|
      photo = PicasaWebAlbums::Photo.new
      photo.id = entry.elements["gphoto:id"].text
      photo.url = entry.elements["media:group/media:content"].attributes["url"]
      photo.width = entry.elements["media:group/media:content"].attributes["width"].to_i
      photo.height = entry.elements["media:group/media:content"].attributes["height"].to_i
      photo.caption = entry.elements["media:group/media:description"].text
      photo.file_name = entry.elements["media:group/media:title"].text
      photos << photo
    end
    return photos
  end
  
  private
  
  def get_tags_string(tags)
    tags_string = ""
    tags.each do |tag|
      tags_string += URI.escape(tag.strip)
      tags_string += '%2C' unless tag == tags.last
    end
    return tags_string
  end
  
  def get_photo_id_from_photo_id_url(photo_id_url)
    start_index = photo_id_url.index('/photoid/') + 9
    slice_of_id_url_to_end = photo_id_url[start_index..-1]
    end_index = slice_of_id_url_to_end.index(/[?|\/]/)
    id = slice_of_id_url_to_end[0...end_index]
    return id
  end
end