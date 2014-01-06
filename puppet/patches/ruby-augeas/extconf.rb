diff -ur ruby-augeas-0.5.0.orig/ext/augeas/extconf.rb ruby-augeas-0.5.0.new/ext/augeas/extconf.rb
--- ruby-augeas-0.5.0.orig/ext/augeas/extconf.rb	2012-01-13 03:44:49.000000000 +0000
+++ ruby-augeas-0.5.0.new/ext/augeas/extconf.rb	2013-04-02 05:08:22.731626703 +0000
@@ -23,12 +23,19 @@
 
 extension_name = '_augeas'
 
-unless pkg_config("augeas")
-    raise "augeas-devel not installed"
-end
+#unless pkg_config("augeas")
+#    raise "augeas-devel not installed"
+#end
+#
+#unless pkg_config("libxml-2.0")
+#    raise "libxml2-devel not installed"
+#end
 
-unless pkg_config("libxml-2.0")
-    raise "libxml2-devel not installed"
-end
+have_library('augeas')
+have_header('augeas.h')
+
+have_library('libxml2')
+have_header('libxml/libxml.h')
+$CFLAGS << ' ' + '-I/usr/include/libxml2'
 
 create_makefile(extension_name)
