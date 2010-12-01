require File.join(File.dirname(__FILE__), *%w[helper])

context "Site" do
  setup do
    path = testpath("examples/test_site.git")
    @site = Gollum::Site.new(path,
                             {:output_path => testpath("examples/site")})
    @site.generate("master")
  end

  test "generate static site" do
    diff = Dir[@site.output_path + "/**/*"].
      map { |f| f.sub(@site.output_path, "") } - ["/Home.html",
                                                  "/Page-One.html",
                                                  "/Page1.html",
                                                  "/Page2.html",
                                                  "/page.html",
                                                  "/static",
                                                  "/static/static.jpg",
                                                  "/static/static.txt"]
    assert_equal([], diff)
  end

  test "render page with layout and link" do
    home_path = File.join(@site.output_path, "Home.html")
    assert_equal(["<html><p>Site test\n",
                  "<a class=\"internal present\" href=\"/Page1.html#test\">Page1#test</a>\n",
                  "<a class=\"internal present\" href=\"/Page-One.html#test\">Page with anchor</a></p></html>\n"],
                 File.open(home_path).readlines)
  end

  test "render page with layout from parent dir" do
    page_path = File.join(@site.output_path, "Page1.html")
    assert_equal(["<html><p>Site test</p></html>\n"], File.open(page_path).readlines)
  end

  test "render page with layout from sub dir" do
    page_path = File.join(@site.output_path, "Page2.html")
    assert_equal(["<html><body><p>Site test</p></body></html>\n"], File.open(page_path).readlines)
  end

  test "page.path is available on template" do
    page_path = File.join(@site.output_path, "page.html")
    assert_equal(["<ul><li>page.html</li></ul>\n"], File.open(page_path).readlines)
  end

  teardown do
    FileUtils.rm_r(@site.output_path)
  end
end

context "Preview" do
  setup do
    path = testpath("examples/uncommitted_untracked_changes")
    @site = Gollum::Site.new(path,
                             {:output_path => testpath("examples/site")})
    @site.preview()
  end

  test "preview site has Home and Foo" do
    diff = Dir[@site.output_path + "/**/*"].
      map { |f| f.sub(@site.output_path, "") } - ["/Home.html",
                                                  "/Foo.html",
                                                  "/Bar.html"]
    assert_equal([], diff)
  end

  test "preview site Home content is uncommitted version" do
    data = IO.read(::File.join(@site.output_path, "Home.html"))
    assert_equal("<p>Hello World\nHello World</p>", data)
  end

  teardown do
    FileUtils.rm_r(@site.output_path)
  end
end
