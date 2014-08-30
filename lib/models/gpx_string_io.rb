class GPXStringIO < StringIO
  attr_accessor :xml_builder, :xml_string, :original_filename

  def initialize(builder, id)
    self.xml_builder = builder
    self.original_filename = "workout_#{id}.gpx"

    self.xml_string = self.xml_builder.to_xml.to_s
    super(self.xml_string)
  end

end
