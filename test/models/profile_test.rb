require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "accepts supported image upload" do
    profile = profiles(:one)

    profile.photo.attach(
      io: File.open(Rails.root.join("public/icon.png")),
      filename: "icon.png",
      content_type: "image/png"
    )

    assert profile.valid?
  end

  test "rejects unsupported image upload type" do
    profile = profiles(:one)

    profile.photo.attach(
      io: StringIO.new("bad file"),
      filename: "bad.txt",
      content_type: "text/plain"
    )

    assert_not profile.valid?
    assert_includes profile.errors[:photo], "must be PNG, JPG, or WEBP"
  end
end
