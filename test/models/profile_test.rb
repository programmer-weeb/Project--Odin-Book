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

  test "rejects photo larger than 5MB" do
    profile = profiles(:one)

    profile.photo.attach(
      io: StringIO.new("x" * (5.megabytes + 1)),
      filename: "large.jpg",
      content_type: "image/jpeg"
    )

    assert_not profile.valid?
    assert_includes profile.errors[:photo], "must be smaller than 5MB"
  end

  test "display_name cannot exceed 50 characters" do
    profile = profiles(:one)
    profile.display_name = "a" * 51
    assert_not profile.valid?
    assert profile.errors[:display_name].present?
  end

  test "bio cannot exceed 1000 characters" do
    profile = profiles(:one)
    profile.bio = "a" * 1001
    assert_not profile.valid?
    assert profile.errors[:bio].present?
  end

  test "bio can be blank" do
    profile = profiles(:one)
    profile.bio = ""
    assert profile.valid?
  end
end
