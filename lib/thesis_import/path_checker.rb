class PathChecker
  def self.index_html_path?(path)
    File.basename(path).match(/index.html?/)
  end

  def self.thesis_path?(path)
    self.common_thesis_path?(path) || self.martin_thesis_path?(path) || self.harada_thesis_path?(path) || self.sakuta_thesis_path?(path) || self.yamaguchi_thesis_path?(path)
  end

  private

    def self.common_thesis_path?(path)
      path.match(/\Athesis.+/)
    end

    def self.martin_thesis_path?(path)
      path.match(/.+_[T|t]\.pdf/)
    end

    def self.harada_thesis_path?(path)
      path.match(/\Aabs\/.+/) && !path.match(/\Aabs\/.+E\.pdf\Z/)
    end

    def self.sakuta_thesis_path?(path)
      path.match(/\Aabstract\/undergraduate/)
    end

    def self.yamaguchi_thesis_path?(path)
      path.match(/(postgrad|undrgrad)\/.+.pdf/)
    end
end
