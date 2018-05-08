package dk.sdu.mmmi.mdsd.project.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext


class ProjectGenerator {
	Resource resource;
	IFileSystemAccess2 fsa;
	IGeneratorContext context;

	new (Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		this.resource = resource
		this.fsa = fsa
		this.context = context
		
		fsa.generateFile( 'build.xml', build);
		fsa.generateFile('manifest.mf', manifest)
		fsa.generateFile('.gitignore', gitignore)
		fsa.generateFile('/nbproject/project.xml', project)
		fsa.generateFile('/nbproject/project.properties', projectProp)

		fsa.generateFile('/nbproject/jfx-impl.xml', jfx)
		var file = fsa.getURI("/nbproject/jfx-impl.xml");
		file.appendFragment(jfxSegment.toString);
		
	}
	
	def jfxSegment() {
		'''
		var profileAvailable = new String(project.getProperty("profile.available"));
		                    if (defined(profileAvailable)) {
		                        var profileAttribute = new org.apache.tools.ant.taskdefs.Manifest.Attribute();
		                        profileAttribute.setName("Profile");
		                        profileAttribute.setValue(new String(project.getProperty("javac.profile")));
		                        man.addConfiguredAttribute(profileAttribute);
		                    }
		                    var perm_elev = new String(project.getProperty("permissions.elevated"));
		                    var cust_perm = new String(project.getProperty("manifest.custom.permissions"));
		                    var cust_cb = new String(project.getProperty("manifest.custom.codebase"));
		                    var sa1 = new org.apache.tools.ant.taskdefs.Manifest.Attribute();
		                    sa1.setName("Codebase");
		                    if(!defined(cust_cb) || cust_cb == "*") {
		                        sa1.setValue("*");
		                        print("Warning: From JDK7u25 the Codebase manifest attribute should be used to restrict JAR repurposing.");
		                        print("         Please set manifest.custom.codebase property to override the current default non-secure value '*'.");
		                    } else {
		                        sa1.setValue(cust_cb);
		                    }
		                    man.addConfiguredAttribute(sa1);
		                    var sa2 = new org.apache.tools.ant.taskdefs.Manifest.Attribute();
		                    sa2.setName("Permissions");
		                    if(!defined(cust_perm)) {
		                        if(isTrue(perm_elev)) {
		                            sa2.setValue("all-permissions");
		                        } else {
		                            sa2.setValue("sandbox");
		                        }
		                    } else {
		                        if(cust_perm == "all-permissions") {
		                            sa2.setValue("all-permissions");
		                        } else {
		                            sa2.setValue("sandbox");
		                        }
		                    }
		                    man.addConfiguredAttribute(sa2);
		                    // Note: see JavaFX Jira issue #RT-25003 if attribute names are created lowercase in manifest
		
		                    jar.perform();
		                ]]>
		            </script>
		            <antcall target="-post-jfx-jar"/>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="deploy-sign">
		        <sequential>
		            <echo message="keystore=${javafx.signjar.keystore}" level="verbose"/>
		            <echo message="storepass=${javafx.signjar.storepass}" level="verbose"/>
		            <echo message="alias=${javafx.signjar.alias}" level="verbose"/>
		            <echo message="keypass=${javafx.signjar.keypass}" level="verbose"/>
		            <signjar keystore="${javafx.signjar.keystore}"
		                storepass="${javafx.signjar.storepass}"
		                alias="${javafx.signjar.alias}"
		                keypass="${javafx.signjar.keypass}">
		                <fileset dir="${jfx.deployment.dir}">
		                    <include name="${jfx.deployment.jar}"/>
		                    <include name="lib${file.separator}*.jar"/>
		                </fileset>
		            </signjar>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="deploy-sign-blob">
		        <sequential>
		            <echo message="keystore=${javafx.signjar.keystore}" level="verbose"/>
		            <echo message="storepass=${javafx.signjar.storepass}" level="verbose"/>
		            <echo message="alias=${javafx.signjar.alias}" level="verbose"/>
		            <echo message="keypass=${javafx.signjar.keypass}" level="verbose"/>
		            <echo message="Launching &lt;fx:signjar&gt; task from ${ant-javafx.jar.location}" level="info"/>
		            <fx:signjar keystore="${javafx.signjar.keystore}"
		                storepass="${javafx.signjar.storepass}"
		                alias="${javafx.signjar.alias}"
		                keypass="${javafx.signjar.keypass}">
		                <fileset dir="${jfx.deployment.dir}">
		                    <include name="${jfx.deployment.jar}"/>
		                    <include name="lib${file.separator}*.jar"/>
		                </fileset>
		            </fx:signjar>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="deploy-sign-preloader">
		        <sequential>
		            <echo message="keystore=${javafx.signjar.keystore}" level="verbose"/>
		            <echo message="storepass=${javafx.signjar.storepass}" level="verbose"/>
		            <echo message="alias=${javafx.signjar.alias}" level="verbose"/>
		            <echo message="keypass=${javafx.signjar.keypass}" level="verbose"/>
		            <signjar keystore="${javafx.signjar.keystore}"
		                storepass="${javafx.signjar.storepass}"
		                alias="${javafx.signjar.alias}"
		                keypass="${javafx.signjar.keypass}">
		                <fileset dir="${jfx.deployment.dir}">
		                    <include name="lib${file.separator}${javafx.preloader.jar.filename}"/>
		                </fileset>
		            </signjar>
		            <signjar keystore="${javafx.signjar.keystore}"
		                storepass="${javafx.signjar.storepass}"
		                alias="${javafx.signjar.alias}"
		                keypass="${javafx.signjar.keypass}">
		                <fileset dir="${jfx.deployment.dir}">
		                    <include name="${jfx.deployment.jar}"/>
		                    <include name="lib${file.separator}*.jar"/>
		                    <exclude name="lib${file.separator}${javafx.preloader.jar.filename}"/>
		                </fileset>
		            </signjar>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="deploy-sign-blob-preloader">
		        <sequential>
		            <echo message="keystore=${javafx.signjar.keystore}" level="verbose"/>
		            <echo message="storepass=${javafx.signjar.storepass}" level="verbose"/>
		            <echo message="alias=${javafx.signjar.alias}" level="verbose"/>
		            <echo message="keypass=${javafx.signjar.keypass}" level="verbose"/>
		            <signjar keystore="${javafx.signjar.keystore}"
		                storepass="${javafx.signjar.storepass}"
		                alias="${javafx.signjar.alias}"
		                keypass="${javafx.signjar.keypass}">
		                <fileset dir="${jfx.deployment.dir}">
		                    <include name="lib${file.separator}${javafx.preloader.jar.filename}"/>
		                </fileset>
		            </signjar>
		            <echo message="Launching &lt;fx:signjar&gt; task from ${ant-javafx.jar.location}" level="info"/>
		            <fx:signjar keystore="${javafx.signjar.keystore}"
		                storepass="${javafx.signjar.storepass}"
		                alias="${javafx.signjar.alias}"
		                keypass="${javafx.signjar.keypass}">
		                <fileset dir="${jfx.deployment.dir}">
		                    <include name="${jfx.deployment.jar}"/>
		                    <include name="lib${file.separator}*.jar"/>
		                    <exclude name="lib${file.separator}${javafx.preloader.jar.filename}"/>
		                </fileset>
		            </fx:signjar>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="deploy-process-template">
		        <sequential>
		            <echo message="javafx.run.htmltemplate = ${javafx.run.htmltemplate}" level="verbose"/>
		            <pathconvert property="javafx.run.htmltemplate.processed">
		                <path path="${javafx.run.htmltemplate}"/>
		                <mapper>
		                     <chainedmapper>
		                          <flattenmapper/>
		                          <globmapper from="*" to="${jfx.deployment.dir}${file.separator}*" casesensitive="no"/>
		                     </chainedmapper>
		                </mapper>
		            </pathconvert>
		            <echo message="javafx.run.htmltemplate.processed = ${javafx.run.htmltemplate.processed}" level="verbose"/>
		        </sequential>
		    </macrodef>
		
		    <!-- fx:deploy scripted call enables passing of arbitrarily long lists of params, vmoptions and callbacks and fx-version dependent behavior -->
		    <macrodef name="deploy-deploy">
		        <sequential>
		            <antcall target="-pre-jfx-deploy"/>
		            <antcall target="-call-pre-jfx-native"/>
		            <echo message="javafx.ant.classpath = ${javafx.ant.classpath}" level="verbose"/>
		            <typedef name="fx_deploy" classname="com.sun.javafx.tools.ant.DeployFXTask" classpath="${javafx.ant.classpath}"/>
		            <echo message="Launching &lt;fx:deploy&gt; task from ${ant-javafx.jar.location}" level="info"/>
		            <property name="pp_deploy_dir" value="${jfx.deployment.dir}"/>
		            <property name="pp_deploy_fs1" value="lib${file.separator}${javafx.preloader.jar.filename}"/>
		            <property name="pp_deploy_fs2" value="lib${file.separator}*.jar"/>
		            <echo message="deploy_deploy: pp_deploy_dir = ${pp_deploy_dir}" level="verbose"/>
		            <echo message="deploy_deploy: pp_deploy_fs1 = ${pp_deploy_fs1}" level="verbose"/>
		            <echo message="deploy_deploy: pp_deploy_fs2 = ${pp_deploy_fs2}" level="verbose"/>
		            <echo message="JavaScript: deploy-deploy" level="verbose"/>
		            <basename property="jfx.deployment.base" file="${jfx.deployment.jar}" suffix=".jar"/>
		            <script language="javascript">
		                <![CDATA[
		                    function isTrue(prop) {
		                        return prop != null && 
		                           (prop.toLowerCase()=="true" || prop.toLowerCase()=="yes" || prop.toLowerCase()=="on");
		                    }                    
		                    function prefix(s, len) {
		                        if(s == null || len <= 0 || s.length == 0) {
		                            return new String("");
		                        }
		                        return new String(s.substr(0, len));
		                    }
		                    function replaceSuffix(s, os, ns) {
		                        return prefix(s, s.indexOf(os)).concat(ns);
		                    }
		                    function startsWith(s, prefix) {
		                        return (s != null) && (s.indexOf(prefix) == 0);
		                    }
		                    function endsWith(s, suffix) {
		                        var i = s.lastIndexOf(suffix);
		                        return  (i != -1) && (i == (s.length - suffix.length));
		                    }
		                    function defined(s) {
		                        return (s != null) && (s != "null") && (s.length > 0);
		                    }
		                    function contains(array, prop) {
		                        for (var i = 0; i < array.length; i++) {
		                            var s1 = new String(array[i]);
		                            var s2 = new String(prop);
		                            if( s1.toLowerCase() == s2.toLowerCase() ) {
		                                return true;
		                            }
		                        }
		                        return false;
		                    }
		                    var S = java.io.File.separator;
		                    var JFXPAR = "javafx.param";
		                    var JFXPARN = "name";
		                    var JFXPARV = "value";
		                    var JFXPARH = "hidden";
		                    var JFXCALLB = "javafx.jscallback";
		                    var JFXLAZY = "download.mode.lazy.jar";
		                    var withpreloader = new String(project.getProperty("app-with-preloader"));
		                    var fx_ant_api_1_1 = new String(project.getProperty("have-fx-ant-api-1.1"));
		                    var fx_ant_api_1_2 = new String(project.getProperty("have-fx-ant-api-1.2"));
		                    var have_jdk_pre7u14 = new String(project.getProperty("have-jdk-pre7u14"));
		                    var fx_in_swing_app = new String(project.getProperty("fx-in-swing-app"));
		                    var debug_in_browser = new String(project.getProperty("project.state.debugging.in.browser"));
		
		                    // get jars with lazy download mode property set
		                    function getLazyJars() {
		                        var jars = new Array();
		                        var keys = project.getProperties().keys();
		                        while(keys.hasMoreElements()) {
		                            var pn = new String(keys.nextElement());
		                            if(startsWith(pn, JFXLAZY)) {
		                                var fname = pn.substring(JFXLAZY.length+1);
		                                jars.push(fname);
		                            }
		                        }
		                        return jars.length > 0 ? jars : null;
		                    }
		                    // set download mode of dependent libraries
		                    function setDownloadMode(fsEager, fsLazy, jars) {
		                        for(var i = 0; i < jars.length; i++) {
		                            fsEager.setExcludes("lib" + S + jars[i]);
		                            fsLazy.setIncludes("lib" + S + jars[i]);
		                        }
		                    }
		                    // convert path to absolute if relative
		                    function derelativizePath(path) {
		                        var f = new java.io.File(path);
		                        if(!f.exists()) {
		                            f = new java.io.File(new String(project.getBaseDir()) + S + path);
		                        }
		                        if(f.exists()) {
		                            try {
		                                return f.getCanonicalPath();
		                            } catch(err) {
		                                return path;
		                            }
		                        }
		                        return path;
		                    }
		                    
		                    // fx:deploy
		                    var deploy = project.createTask("fx_deploy");
		                    deploy.setProject(project);
		                    var width = new String(project.getProperty("javafx.width"));
		                    var height = new String(project.getProperty("javafx.height"));
		                    var outdir = new String(project.getProperty("jfx.deployment.dir"));
		                    var embedJNLP = new String(project.getProperty("javafx.deploy.embedJNLP"));
		                    var updatemode = new String(project.getProperty("update-mode"));
		                    var outfile = new String(project.getProperty("application.title"));
		                    var includeDT = new String(project.getProperty("javafx.deploy.includeDT"));
		                    var offline = new String(project.getProperty("javafx.deploy.allowoffline"));
		                    if (width.indexOf("%") != -1) {
		                        deploy.setEmbeddedWidth(width);
		                        deploy.setWidth(800);
		                    } else {
		                        deploy.setWidth(width);
		                    }
		                    if (height.indexOf("%") != -1) {
		                        deploy.setEmbeddedHeight(height);
		                        deploy.setHeight(600);
		                    } else {
		                        deploy.setHeight(height);
		                    }
		                    deploy.setOutdir(outdir);
		                    deploy.setEmbedJNLP(isTrue(embedJNLP));
		                    deploy.setUpdateMode(updatemode);
		                    deploy.setOutfile(outfile);
		                    deploy.setIncludeDT(isTrue(includeDT));
		                    if(defined(offline)) {
		                        if(isTrue(fx_ant_api_1_1)) {
		                            deploy.setOfflineAllowed(isTrue(offline));
		                        } else {
		                            print("Warning: offlineAllowed not supported by this version of JavaFX SDK deployment Ant task. Please upgrade JavaFX to 2.0.2 or higher.");
		                        }
		                    }
		                    // native packaging (time consuming, thus applied in explicit build only)
		                    var nativeEnabled = new String(project.getProperty("do.build.native.package"));
		                    var nativeType = new String(project.getProperty("javafx.native.bundling.type"));
		                    var projStateRun = new String(project.getProperty("project.state.running"));
		                    var projStateDbg = new String(project.getProperty("project.state.debugging"));
		                    var projStatePrf = new String(project.getProperty("project.state.profiling"));
		                    if(isTrue(nativeEnabled) && defined(nativeType) && nativeType != "none") {
		                        if(!isTrue(projStateRun) && !isTrue(projStateDbg) && !isTrue(projStatePrf)) {
		                            if(isTrue(fx_ant_api_1_2)) {
		                                deploy.setNativeBundles(nativeType);
		                                print("Note: To create native bundles the <fx:deploy> task may require external tools. See JavaFX 2.2+ documentation for details.");
		                                print("");
		                                print("Launching <fx:deploy> in native packager mode...");
		                            } else {
		                                print("Warning: Native packaging is not supported by this version of JavaFX SDK deployment Ant task. Please upgrade to JDK 7u6 or higher.");
		                            }
		                        }
		                    }
		
		                    // fx:application
		                    var app = deploy.createApplication();
		                    app.setProject(project);
		                    var title = new String(project.getProperty("application.title"));
		                    var mainclass;
		                    if(isTrue(fx_in_swing_app) && isTrue(fx_ant_api_1_2)) {
		                        mainclass = new String(project.getProperty("main.class"));
		                        app.setToolkit("swing");
		                    } else {
		                        mainclass = new String(project.getProperty("javafx.main.class"));
		                    }
		                    var fallback = new String(project.getProperty("javafx.fallback.class"));
		                    app.setName(title);
		                    app.setMainClass(mainclass);
		                    app.setFallbackClass(fallback);
		                    if(isTrue(withpreloader)) {
		                        preloaderclass = new String(project.getProperty("javafx.preloader.class"));
		                        app.setPreloaderClass(preloaderclass);
		                    }
		                    var appversion = new String(project.getProperty("javafx.application.implementation.version"));
		                    if(defined(appversion)) {
		                        app.setVersion(appversion);
		                    } else {
		                        app.setVersion("1.0");
		                    }
		                    // fx:param, fx:argument
		                    var searchHides = project.getProperties().keys();
		                    var hides = new Array();
		                    while(searchHides.hasMoreElements()) {
		                        // collect all hidden property names
		                        var pns = new String(searchHides.nextElement());
		                        if(startsWith(pns, JFXPAR) && endsWith(pns, JFXPARN)) {
		                            var propns = new String(project.getProperty(pns));
		                            var phs = replaceSuffix(pns, JFXPARN, JFXPARH);
		                            var proph = new String(project.getProperty(phs));
		                            if(isTrue(proph)) {
		                                hides.push(propns);
		                            }
		                         }
		                    }
		                    var keys = project.getProperties().keys();
		                    while(keys.hasMoreElements()) {
		                        var pn = new String(keys.nextElement());
		                        if(startsWith(pn, JFXPAR) && endsWith(pn, JFXPARN)) {
		                            var propn = new String(project.getProperty(pn));
		                            if(defined(propn) && !contains(hides, propn)) {
		                                var pv = replaceSuffix(pn, JFXPARN, JFXPARV);
		                                var propv = new String(project.getProperty(pv));
		                                if(defined(propv)) {
		                                    var par = app.createParam();
		                                    par.setName(propn);
		                                    par.setValue(propv);
		                                } else {
		                                    if(isTrue(fx_ant_api_1_1)) {
		                                        var arg = app.createArgument();
		                                        arg.addText(propn);
		                                    } else {
		                                        print("Warning: Unnamed parameters not supported by this version of JavaFX SDK deployment Ant tasks. Upgrade JavaFX to 2.0.2 or higher.");
		                                    }
		                                }
		                            }
		                        }
		                    }
		                    
		                    // fx:resources
		                    var res = deploy.createResources();
		                    res.setProject(project);
		                    var deploydir = new String(project.getProperty("pp_deploy_dir"));
		                    if(isTrue(withpreloader)) {
		                        var f1 = res.createFileSet();
		                        f1.setProject(project);
		                        f1.setDir(new java.io.File(deploydir));
		                        var i1 = new String(project.getProperty("pp_deploy_fs1"));
		                        f1.setIncludes(i1);
		                        f1.setRequiredFor("preloader");
		                        var f2 = res.createFileSet();
		                        f2.setProject(project);
		                        f2.setDir(new java.io.File(deploydir));
		                        var i2a = new String(project.getProperty("jfx.deployment.jar"));
		                        var i2b = new String(project.getProperty("pp_deploy_fs2"));
		                        var e2c = new String(project.getProperty("pp_deploy_fs1"));
		                        f2.setIncludes(i2a);
		                        f2.setIncludes(i2b);
		                        f2.setExcludes(e2c);
		                        f2.setRequiredFor("startup");
		                        var lazyjars = getLazyJars();
		                        if(lazyjars != null) {
		                            var f3 = res.createFileSet();
		                            f3.setProject(project);
		                            f3.setDir(new java.io.File(deploydir));
		                            f3.setRequiredFor("runtime");
		                            setDownloadMode(f2,f3,lazyjars);
		                        }
		                    } else {
		                        var fn = res.createFileSet();
		                        fn.setProject(project);
		                        fn.setDir(new java.io.File(deploydir));
		                        var ia = new String(project.getProperty("jfx.deployment.jar"));
		                        var ib = new String(project.getProperty("pp_deploy_fs2"));
		                        fn.setIncludes(ia);
		                        fn.setIncludes(ib);
		                        fn.setRequiredFor("startup");
		                        var lazyjars = getLazyJars();
		                        if(lazyjars != null) {
		                            var fn2 = res.createFileSet();
		                            fn2.setProject(project);
		                            fn2.setDir(new java.io.File(deploydir));
		                            fn2.setRequiredFor("runtime");
		                            setDownloadMode(fn,fn2,lazyjars);
		                        }
		                    }
		                    
		                    // fx:info
		                    var info = deploy.createInfo();
		                    info.setProject(project);
		                    var vendor = new String(project.getProperty("application.vendor"));
		                    var description = new String(project.getProperty("application.desc"));
		                    info.setTitle(title); // title known from before
		                    info.setVendor(vendor);
		                    info.setDescription(description);
		                    var splash = new String(project.getProperty("javafx.deploy.splash"));
		                    if(defined(splash)) {
		                        if(isTrue(fx_ant_api_1_1)) {
		                            var sicon = info.createSplash();
		                            sicon.setHref(splash);
		                            sicon.setMode("any");
		                            print("Adding splash image reference: " + splash);
		                        } else {
		                            print("Warning: Splash Image not supported by this version of JavaFX SDK deployment Ant task. Please upgrade JavaFX to 2.0.2 or higher.");
		                        }
		                    }
		                    if(isTrue(nativeEnabled) && defined(nativeType) && nativeType != "none") {
		                        var icon = new String(project.getProperty("javafx.deploy.icon.native"));
		                        if(defined(icon)) {
		                            if(isTrue(fx_ant_api_1_2) && !isTrue(have_jdk_pre7u14)) {
		                                var dicon = derelativizePath(icon);
		                                // create temporary icon copy renamed to application name (required by native packager)
		                                var baseDir = new String(project.getProperty("basedir"));
		                                var buildDir = new String(project.getProperty("build.dir"));
		                                var deployBase = new String(project.getProperty("jfx.deployment.base"));
		                                var copyTask = project.createTask("copy");
		                                var source = new java.io.File(dicon);
		                                var sourceName = new String(source.getName());
		                                var lastDot = sourceName.lastIndexOf(".");
		                                var sourceExt;
		                                if(lastDot >=0) {
		                                    sourceExt = sourceName.substr(lastDot);
		                                } else {
		                                    sourceExt = new String("");
		                                }
		                                var target = new java.io.File(baseDir.concat(S).concat(buildDir).concat(S).concat("icon").concat(S).concat(deployBase).concat(sourceExt));
		                                copyTask.setFile(source);
		                                copyTask.setTofile(target);
		                                copyTask.setFlatten(true);
		                                copyTask.setFailOnError(false);
		                                copyTask.perform();
		                                var tempicon;
		                                if(target.exists()) {
		                                    try {
		                                        tempicon = target.getCanonicalPath();
		                                    } catch(err) {
		                                        tempicon = dicon;
		                                    }
		                                } else {
		                                    tempicon = dicon;
		                                }
		                                var nicon = info.createIcon();
		                                nicon.setHref(tempicon);
		                                print("Source native icon reference: " + dicon);
		                                print("Processed native icon reference: " + tempicon);
		                            } else {
		                                print("Warning: Native Package icon not supported by this version of JavaFX SDK deployment Ant task. Please upgrade to JDK7u14.");
		                            }
		                        }
		                    } else {
		                        var icon = new String(project.getProperty("javafx.deploy.icon"));
		                        if(defined(icon)) {
		                            if(isTrue(fx_ant_api_1_1)) {
		                                var iicon = info.createIcon();
		                                iicon.setHref(icon);
		                                print("Adding WebStart icon reference: " + icon);
		                            } else {
		                                print("Warning: WebStart Icon not supported by this version of JavaFX SDK deployment Ant task. Please upgrade JavaFX to 2.0.2 or higher.");
		                            }
		                        }
		                    }
		                    
		                    // fx:permissions
		                    var perm = deploy.createPermissions();
		                    perm.setProject(project);
		                    var elev = new String(project.getProperty("permissions.elevated"));
		                    perm.setElevated(isTrue(elev));
		                    
		                    // fx:preferences
		                    var pref = deploy.createPreferences();
		                    pref.setProject(project);
		                    var scut = new String(project.getProperty("javafx.deploy.adddesktopshortcut"));
		                    var instp = new String(project.getProperty("javafx.deploy.installpermanently"));
		                    var smenu = new String(project.getProperty("javafx.deploy.addstartmenushortcut"));
		                    pref.setShortcut(isTrue(scut));
		                    pref.setInstall(isTrue(instp));
		                    pref.setMenu(isTrue(smenu));
		
		                    // fx:template
		                    var templ = new String(project.getProperty("javafx.run.htmltemplate"));
		                    var templp = new String(project.getProperty("javafx.run.htmltemplate.processed"));
		                    if(defined(templ) && defined(templp)) {
		                        var temp = deploy.createTemplate();
		                        temp.setProject(project);
		                        temp.setFile(new java.io.File(templ));
		                        temp.setTofile(new java.io.File(templp));
		                    }
		
		                    // fx:platform
		                    var plat = deploy.createPlatform();
		                    plat.setProject(project);
		                    var requestRT = new String(project.getProperty("javafx.deploy.request.runtime"));
		                    if(defined(requestRT)) {
		                        plat.setJavafx(requestRT);
		                    }
		                    var jvmargs = new String(project.getProperty("run.jvmargs"));
		                    if(defined(jvmargs)) {
		                        var jvmargss = jvmargs.split(" ");
		                        for(var i = 0; i < jvmargss.length; i++) {
		                            if(defined(jvmargss[i])) {
		                                var vmarg = plat.createJvmarg();
		                                vmarg.setValue(jvmargss[i]);
		                            }
		                        }
		                    }
		                    if(isTrue(debug_in_browser)) {
		                        var vmarg = plat.createJvmarg();
		                        vmarg.setValue(new String("-ea:javafx.browserdebug"));
		                    }
		                    if(isTrue(nativeEnabled) && defined(nativeType) && nativeType != "none") {
		                        if(!isTrue(projStateRun) && !isTrue(projStateDbg) && !isTrue(projStatePrf)) {
		                            if(plat.setBasedir) {
		                                var sdkdir = new String(project.getProperty("javafx.sdk"));
		                                if(defined(sdkdir)) {
		                                    plat.setBasedir(sdkdir);
		                                }
		                            } else {
		                                print("Note: the current version of native packager Ant task can bundle the default JRE only.");
		                            }
		                        }
		                    }
		                    
		                    // fx:callbacks
		                    var callbs = deploy.createCallbacks();
		                    callbs.setProject(project);
		                    var keys = project.getProperties().keys();
		                    while(keys.hasMoreElements()) {
		                        var pn = new String(keys.nextElement());
		                        if(startsWith(pn, JFXCALLB)) {
		                            var prop = new String(project.getProperty(pn));
		                            if(defined(prop)) {
		                                var cname = pn.substring(JFXCALLB.length+1);
		                                var cb = callbs.createCallback();
		                                cb.setProject(project);
		                                cb.setName(cname);
		                                cb.addText(prop);
		                            }
		                        }
		                    }
		                    
		                    deploy.perform();
		                ]]>
		            </script>
		            <antcall target="-post-jfx-deploy"/>
		            <antcall target="-call-post-jfx-native"/>
		        </sequential>
		    </macrodef>
		
		    <!-- JavaFX SDK 2.0.x and 2.1.x deploy task can not generate pre-FX jnlp which is needed for FX-in-Swing projects-->
		    <macrodef name="deploy-deploy-swing">
		        <sequential>
		            <antcall target="-pre-jfx-deploy"/>
		            <local name="permissions-elevated-token"/>
		            <condition property="permissions-elevated-token" value="${line.separator}    &lt;security&gt;${line.separator}        &lt;all-permissions/&gt;${line.separator}    &lt;/security&gt;" else="">
		                <isset property="permissions-elevated"/>
		            </condition>
		            <local name="offline-allowed-token"/>
		            <condition property="offline-allowed-token" value="${line.separator}        &lt;offline-allowed/&gt;" else="">
		                <isset property="offline-allowed"/>
		            </condition>
		            <local name="update-mode-background-token"/>
		            <condition property="update-mode-background-token" value="background" else="always">
		                <isset property="update-mode-background"/>
		            </condition>
		            <local name="html-template-processed-available"/>
		            <condition property="html-template-processed-available">
		                <and>
		                    <isset property="javafx.run.htmltemplate.processed"/>
		                    <not>
		                        <equals arg1="${javafx.run.htmltemplate.processed}" arg2=""/>
		                    </not>
		                </and>
		            </condition>
		            <local name="javafx.deploy.icon.basename"/>
		            <basename property="javafx.deploy.icon.basename" file="${javafx.deploy.icon}"/>
		            <local name="local-icon-filename-available"/>
		            <condition property="local-icon-filename-available">
		                <and>
		                    <isset property="icon-available"/>
		                    <isset property="javafx.deploy.icon.basename"/>
		                    <not><equals arg1="${javafx.deploy.icon.basename}" arg2=""/></not>
		                    <not><contains string="${javafx.deploy.icon.basename}" substring="$${javafx" casesensitive="false"/></not>
		                    <not><contains string="${javafx.deploy.icon}" substring="http:" casesensitive="false"/></not>
		                </and>
		            </condition>
		            <local name="icon-token"/>
		            <condition property="icon-token" value="${line.separator}        &lt;icon href=&quot;${javafx.deploy.icon.basename}&quot; kind=&quot;default&quot;/&gt;">
		                <isset property="local-icon-filename-available"/>
		            </condition>
		            <condition property="icon-token" value="${line.separator}        &lt;icon href=&quot;${javafx.deploy.icon}&quot; kind=&quot;default&quot;/&gt;" else="">
		                <isset property="icon-available"/>
		            </condition>
		            <basename property="dist.filename" file="${dist.jar}" suffix=".jar"/>
		            <length file="${dist.jar}" property="dist.jar.size" />
		            <local name="vmargs-token"/>
		            <condition property="vmargs-token" value="java-vm-args=&quot;${run.jvmargs}&quot; " else="">
		                <isset property="vmargs-available"/>
		            </condition>
		            <local name="applet-params-token"/>
		            <local name="application-args-token"/>
		            <echo message="JavaScript: deploy-deploy-swing 1" level="verbose"/>
		            <script language="javascript">
		                <![CDATA[
		                    function prefix(s, len) {
		                        if(s == null || len <= 0 || s.length == 0) {
		                            return new String("");
		                        }
		                        return new String(s.substr(0, len));
		                    }
		                    function replaceSuffix(s, os, ns) {
		                        return prefix(s, s.indexOf(os)).concat(ns);
		                    }
		                    function startsWith(s, prefix) {
		                        return (s != null) && (s.indexOf(prefix) == 0);
		                    }
		                    function endsWith(s, suffix) {
		                        var i = s.lastIndexOf(suffix);
		                        return  (i != -1) && (i == (s.length - suffix.length));
		                    }
		                    function defined(s) {
		                        return (s != null) && (s != "null") && (s.length > 0);
		                    }
		                    var JFXPAR = "javafx.param";
		                    var JFXPARN = "name";
		                    var JFXPARV = "value";
		
		                    var params = new java.lang.StringBuilder();
		                    var args = new java.lang.StringBuilder();
		                    var keys = project.getProperties().keys();
		                    while(keys.hasMoreElements()) {
		                        var pn = new String(keys.nextElement());
		                        if(startsWith(pn, JFXPAR) && endsWith(pn, JFXPARN)) {
		                            var propn = new String(project.getProperty(pn));
		                            if(defined(propn)) {
		                                var pv = replaceSuffix(pn, JFXPARN, JFXPARV);
		                                var propv = new String(project.getProperty(pv));
		                                if(defined(propv)) {
		                                    params.append("\n        <param name=\"");
		                                    params.append(propn);
		                                    params.append("\" value=\"");
		                                    params.append(propv);
		                                    params.append("\"/>");
		                                    args.append("\n        <argument>");
		                                    args.append(propn);
		                                    args.append("=");
		                                    args.append(propv);
		                                    args.append("</argument>");
		                                } else {
		                                    params.append("\n        <param name=\"");
		                                    params.append(propn);
		                                    params.append("\" value=\"\"/>");
		                                    args.append("\n        <argument>");
		                                    args.append(propn);
		                                    args.append("</argument>");
		                                }
		                            }
		                        }
		                    }
		                    project.setProperty("applet-params-token", new String(params.toString()));
		                    project.setProperty("application-args-token", new String(args.toString()));
		                ]]>
		            </script>
		            <local name="application.desc.processed"/>
		            <condition property="application.desc.processed" value="${application.desc}" else="Swing applet embedding JavaFX components.">
		                <isset property="application.desc"/>
		            </condition>
		            <filterchain id="jnlp.template.filter">
		                <replacetokens>
		                    <token key="NAME" value="${dist.filename}"/>
		                    <token key="MAINCLASS" value="${main.class}"/>
		                    <token key="FILESIZE" value="${dist.jar.size}"/>
		                    <token key="VENDOR" value="${application.vendor}"/>
		                    <token key="TITLE" value="${application.title}"/>
		                    <token key="DESCRIPTION" value="${application.desc.processed}"/>
		                    <token key="WIDTH" value="${javafx.run.width}"/>
		                    <token key="HEIGHT" value="${javafx.run.height}"/>
		                    <token key="PERMISSIONS" value="${permissions-elevated-token}"/>
		                    <token key="OFFLINE" value="${offline-allowed-token}"/>
		                    <token key="UPDATEMODE" value="${update-mode-background-token}"/>
		                    <token key="ICON" value="${icon-token}"/>
		                    <token key="VMARGS" value="${vmargs-token}"/>
		                    <token key="PARAMETERS" value="${applet-params-token}"/>
		                    <token key="ARGUMENTS" value="${application-args-token}"/>
		                </replacetokens>
		            </filterchain>
		            <copy file="${basedir}${file.separator}nbproject${file.separator}templates${file.separator}FXSwingTemplateApplication.jnlp" 
		                    tofile="${dist.dir}${file.separator}${dist.filename}_application.jnlp" >
		                    <filterchain refid="jnlp.template.filter"/>
		            </copy>        
		            <copy file="${basedir}${file.separator}nbproject${file.separator}templates${file.separator}FXSwingTemplateApplet.jnlp" 
		                    tofile="${dist.dir}${file.separator}${dist.filename}_applet.jnlp" >
		                    <filterchain refid="jnlp.template.filter"/>
		            </copy>        
		            <copy file="${basedir}${file.separator}nbproject${file.separator}templates${file.separator}FXSwingTemplate.html" 
		                    tofile="${dist.dir}${file.separator}${dist.filename}.html" >
		                    <filterchain refid="jnlp.template.filter"/>
		            </copy>
		            <echo message="JavaScript: deploy-deploy-swing 2" level="verbose"/>
		            <script language="javascript">
		                <![CDATA[
		                    function startsWith(s, prefix) {
		                        return (s != null) && (s.indexOf(prefix) == 0);
		                    }
		                    function defined(s) {
		                        return (s != null) && (s != "null") && (s.length > 0);
		                    }
		                    var PREF = "file:";
		                    var doCopyIcon = new String(project.getProperty("local-icon-filename-available"));
		                    if(defined(doCopyIcon)) {
		                        var iconProp = new String(project.getProperty("javafx.deploy.icon"));
		                        if(startsWith(iconProp, PREF)) {
		                            iconProp = iconProp.slice(PREF.length);
		                        }
		                        while(iconProp.charAt(0) == "/") {
		                            iconProp = iconProp.slice(1);
		                        }
		                        var S = java.io.File.separator;
		                        var baseDir = new String(project.getProperty("basedir"));
		                        var distDir = new String(project.getProperty("dist.dir"));
		                        var copyTask = new String(project.createTask("copy"));
		                        var source = new java.io.File(iconProp);
		                        var target = new java.io.File(baseDir.concat(S).concat(distDir));
		                        copyTask.setFile(source);
		                        copyTask.setTodir(target);
		                        copyTask.setFlatten(true);
		                        copyTask.setFailOnError(false);
		                        copyTask.perform();
		                    }
		                    var doCopyHTMLFrom = new String(project.getProperty("html-template-available"));
		                    var doCopyHTMLTo = new String(project.getProperty("html-template-processed-available"));
		                    if(defined(doCopyHTMLFrom) && defined(doCopyHTMLTo)) {
		                        var htmlFrom = new String(project.getProperty("javafx.run.htmltemplate"));
		                        if(startsWith(htmlFrom, PREF)) {
		                            htmlFrom = htmlFrom.slice(PREF.length);
		                        }
		                        while(startsWith(htmlFrom, "/")) {
		                            htmlFrom = htmlFrom.slice(1);
		                        }
		                        var htmlTo = new String(project.getProperty("javafx.run.htmltemplate.processed"));
		                        if(startsWith(htmlTo, PREF)) {
		                            htmlTo = htmlTo.slice(PREF.length);
		                        }
		                        while(startsWith(htmlTo, "/")) {
		                            htmlTo = htmlTo.slice(1);
		                        }
		                        var copyTask = project.createTask("copy");
		                        var source = new java.io.File(htmlFrom);
		                        var target = new java.io.File(htmlTo);
		                        copyTask.setFile(source);
		                        copyTask.setTofile(target);
		                        copyTask.setFailOnError(false);
		                        copyTask.perform();
		                    }
		                ]]>
		            </script>
		            <antcall target="-post-jfx-deploy"/>
		        </sequential>
		    </macrodef>
		
		
		    <!-- Fallback Project Deployment Macros To Support At Least Partially JDKs Without JavaScript Support -->
		    
		    <macrodef name="fallback-deploy-application-def">
		        <sequential>
		            <echo message="Warning: Parameters (if any) not passed to &lt;fx:application&gt; in fallback build mode due to JDK missing JavaScript support."/>
		            <fx:application id="fxApp"
		                name="${application.title}"
		                mainClass="${javafx.main.class}"
		                fallbackClass="${javafx.fallback.class}">
		                <!-- PARAMETERS NOT PASSED IN FALLBACK -->
		            </fx:application>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="fallback-deploy-application-def-preloader">
		        <sequential>
		            <echo message="Warning: Parameters (if any) not passed to &lt;fx:application&gt; in fallback build mode due to JDK missing JavaScript support."/>
		            <fx:application id="fxApp"
		                name="${application.title}"
		                mainClass="${javafx.main.class}"
		                preloaderClass="${javafx.preloader.class}"
		                fallbackClass="${javafx.fallback.class}">
		                <!-- PARAMETERS NOT PASSED IN FALLBACK -->
		            </fx:application>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="fallback-deploy-application-def-swing">
		        <sequential>
		            <echo message="Warning: Parameters (if any) not passed to &lt;fx:application&gt; in fallback build mode due to JDK missing JavaScript support."/>
		            <fx:application id="fxApp"
		                name="${application.title}"
		                mainClass="${main.class}"
		                fallbackClass="${javafx.fallback.class}"
		                toolkit="swing">
		                <!-- PARAMETERS NOT PASSED IN FALLBACK -->
		            </fx:application>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="fallback-deploy-resources">
		        <sequential>
		            <fx:resources id="appRes">
		                <fx:fileset requiredFor="startup" dir="${jfx.deployment.dir}">
		                    <include name="${jfx.deployment.jar}"/>
		                    <include name="lib${file.separator}*.jar"/>
		                    <exclude name="lib${file.separator}${jfx.deployment.jar}"/>
		                </fx:fileset>
		            </fx:resources>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="fallback-deploy-resources-preloader">
		        <sequential>
		            <fx:resources id="appRes">
		                <fx:fileset requiredFor="preloader" dir="${jfx.deployment.dir}">
		                    <include name="lib${file.separator}${javafx.preloader.jar.filename}"/>
		                </fx:fileset>
		                <fx:fileset requiredFor="startup" dir="${jfx.deployment.dir}">
		                    <include name="${jfx.deployment.jar}"/>
		                    <include name="lib${file.separator}*.jar"/>
		                    <exclude name="lib${file.separator}${javafx.preloader.jar.filename}"/>
		                    <exclude name="lib${file.separator}${jfx.deployment.jar}"/>
		                </fx:fileset>
		            </fx:resources>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="fallback-deploy-jar">
		        <sequential>
		            <antcall target="-pre-jfx-jar"/>
		            <fx:jar destfile="${jfx.deployment.dir}${file.separator}${jfx.deployment.jar}">
		                <fx:application refid="fxApp"/>
		                <fx:resources refid="appRes"/>
		                <fileset dir="${build.classes.dir}">
		                    <exclude name="**${file.separator}*.${css-exclude-ext}"/>
		                </fileset>
		                <manifest>
		                    <attribute name="Implementation-Vendor" value="${application.vendor}"/>
		                    <attribute name="Implementation-Title" value="${application.title}"/>
		                    <attribute name="Implementation-Version" value="1.0"/>
		                </manifest>
		            </fx:jar>
		            <antcall target="-post-jfx-jar"/>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="fallback-deploy-deploy">
		        <sequential>
		            <antcall target="-pre-jfx-deploy"/>
		            <echo message="Warning: JVM Arguments and Callbacks (if any) not passed to &lt;fx:deploy&gt; in fallback build mode due to JDK missing JavaScript support."/>
		            <fx:deploy width="${javafx.width}" height="${javafx.height}"
		                      outdir="${jfx.deployment.dir}" embedjnlp="true" updatemode="${update-mode}"
		                      outfile="${application.title}" includeDT="${javafx.deploy.includeDT}">
		                <fx:application refid="fxApp"/>
		                <fx:resources refid="appRes"/>
		                <fx:info title="${application.title}" vendor="${application.vendor}"/>
		                <fx:permissions elevated="${permissions.elevated}"/>
		                <fx:preferences shortcut="${javafx.deploy.adddesktopshortcut}" install="${javafx.deploy.installpermanently}" menu="${javafx.deploy.addstartmenushortcut}"/>
		                <!-- PLATFORM NOT PASSED IN FALLBACK -->
		                <!-- CALLBACKS NOT PASSED IN FALLBACK -->
		            </fx:deploy>
		            <antcall target="-post-jfx-deploy"/>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="fallback-deploy-deploy-template">
		        <sequential>
		            <antcall target="-pre-jfx-deploy"/>
		            <echo message="Warning: JVM Arguments and Callbacks (if any) not passed to &lt;fx:deploy&gt; in fallback build mode due to JDK missing JavaScript support."/>
		            <deploy-process-template/>
		            <fx:deploy width="${javafx.width}" height="${javafx.height}"
		                      outdir="${jfx.deployment.dir}" embedjnlp="true" updatemode="${update-mode}"
		                      outfile="${application.title}" includeDT="${javafx.deploy.includeDT}">
		                <fx:application refid="fxApp"/>
		                <fx:resources refid="appRes"/>
		                <fx:info title="${application.title}" vendor="${application.vendor}"/>
		                <fx:permissions elevated="${permissions.elevated}"/>
		                <fx:preferences shortcut="${javafx.deploy.adddesktopshortcut}" install="${javafx.deploy.installpermanently}" menu="${javafx.deploy.addstartmenushortcut}"/>
		                <fx:template file="${javafx.run.htmltemplate}" tofile="${javafx.run.htmltemplate.processed}"/>
		                <!-- PLATFORM NOT PASSED IN FALLBACK -->
		                <!-- CALLBACKS NOT PASSED IN FALLBACK -->
		            </fx:deploy>
		            <antcall target="-post-jfx-deploy"/>
		        </sequential>
		    </macrodef>
		
		
		    <!-- Project Deployment Targets -->
		
		    <target name="-check-sign" depends="-check-project,-javafx-init-keystore" if="javafx.signed.true+signjars.task.available">
		        <condition property="sign-nopreloader-notemplate">
		            <and>
		                <isset property="app-without-preloader"/>
		                <not><isset property="html-template-available"/></not>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		                <not><isset property="use-blob-signing"/></not>
		            </and>
		        </condition>
		        <condition property="sign-preloader-notemplate">
		            <and>
		                <isset property="app-with-preloader"/>
		                <not><isset property="html-template-available"/></not>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		                <not><isset property="use-blob-signing"/></not>
		            </and>
		        </condition>
		        <condition property="sign-nopreloader-template">
		            <and>
		                <isset property="app-without-preloader"/>
		                <isset property="html-template-available"/>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		                <not><isset property="use-blob-signing"/></not>
		            </and>
		        </condition>
		        <condition property="sign-preloader-template">
		            <and>
		                <isset property="app-with-preloader"/>
		                <isset property="html-template-available"/>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		                <not><isset property="use-blob-signing"/></not>
		            </and>
		        </condition>
		        <condition property="sign-nopreloader-notemplate-swing">
		            <and>
		                <isset property="app-without-preloader"/>
		                <not><isset property="html-template-available"/></not>
		                <isset property="fx-in-swing-app-workaround"/>
		                <not><isset property="use-blob-signing"/></not>
		            </and>
		        </condition>
		        <condition property="sign-nopreloader-template-swing">
		            <and>
		                <isset property="app-without-preloader"/>
		                <isset property="html-template-available"/>
		                <isset property="fx-in-swing-app-workaround"/>
		                <not><isset property="use-blob-signing"/></not>
		            </and>
		        </condition>
		        <condition property="sign-blob-nopreloader-notemplate">
		            <and>
		                <isset property="app-without-preloader"/>
		                <not><isset property="html-template-available"/></not>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		                <isset property="use-blob-signing"/>
		            </and>
		        </condition>
		        <condition property="sign-blob-preloader-notemplate">
		            <and>
		                <isset property="app-with-preloader"/>
		                <not><isset property="html-template-available"/></not>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		                <isset property="use-blob-signing"/>
		            </and>
		        </condition>
		        <condition property="sign-blob-nopreloader-template">
		            <and>
		                <isset property="app-without-preloader"/>
		                <isset property="html-template-available"/>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		                <isset property="use-blob-signing"/>
		            </and>
		        </condition>
		        <condition property="sign-blob-preloader-template">
		            <and>
		                <isset property="app-with-preloader"/>
		                <isset property="html-template-available"/>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		                <isset property="use-blob-signing"/>
		            </and>
		        </condition>
		        <condition property="sign-blob-nopreloader-notemplate-swing">
		            <and>
		                <isset property="app-without-preloader"/>
		                <not><isset property="html-template-available"/></not>
		                <isset property="fx-in-swing-app-workaround"/>
		                <isset property="use-blob-signing"/>
		            </and>
		        </condition>
		        <condition property="sign-blob-nopreloader-template-swing">
		            <and>
		                <isset property="app-without-preloader"/>
		                <isset property="html-template-available"/>
		                <isset property="fx-in-swing-app-workaround"/>
		                <isset property="use-blob-signing"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-check-nosign" depends="-check-project">
		        <condition property="nosign-nopreloader-notemplate">
		            <and>
		                <isset property="app-without-preloader"/>
		                <not><isset property="html-template-available"/></not>
		                <not><isset property="javafx.signed.true"/></not>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		            </and>
		        </condition>
		        <condition property="nosign-preloader-notemplate">
		            <and>
		                <isset property="app-with-preloader"/>
		                <not><isset property="html-template-available"/></not>
		                <not><isset property="javafx.signed.true"/></not>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		            </and>
		        </condition>
		        <condition property="nosign-nopreloader-template">
		            <and>
		                <isset property="app-without-preloader"/>
		                <isset property="html-template-available"/>
		                <not><isset property="javafx.signed.true"/></not>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		            </and>
		        </condition>
		        <condition property="nosign-preloader-template">
		            <and>
		                <isset property="app-with-preloader"/>
		                <isset property="html-template-available"/>
		                <not><isset property="javafx.signed.true"/></not>
		                <not><isset property="fx-in-swing-app-workaround"/></not>
		            </and>
		        </condition>
		        <condition property="nosign-nopreloader-notemplate-swing">
		            <and>
		                <isset property="app-without-preloader"/>
		                <not><isset property="html-template-available"/></not>
		                <not><isset property="javafx.signed.true"/></not>
		                <isset property="fx-in-swing-app-workaround"/>
		            </and>
		        </condition>
		        <condition property="nosign-nopreloader-template-swing">
		            <and>
		                <isset property="app-without-preloader"/>
		                <isset property="html-template-available"/>
		                <not><isset property="javafx.signed.true"/></not>
		                <isset property="fx-in-swing-app-workaround"/>
		            </and>
		        </condition>
		    </target>
		
		
		    <!-- WITH SIGNING -->
		
		    <!-- project without preloader -->
		    <!-- no html template -->
		    <target name="-deploy-app-sign-nopreloader-notemplate" depends="-check-sign" if="sign-nopreloader-notemplate" unless="preloader-app">
		        <echo message="-deploy-app-sign-nopreloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign/>
		        <deploy-deploy/>
		    </target>
		    <target name="-deploy-app-sign-blob-nopreloader-notemplate" depends="-check-sign" if="sign-blob-nopreloader-notemplate" unless="preloader-app">
		        <echo message="-deploy-app-sign-blob-nopreloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign-blob/>
		        <deploy-deploy/>
		    </target>
		
		    <!-- project with preloader -->
		    <!-- no html template -->
		    <target name="-deploy-app-sign-preloader-notemplate" depends="-check-sign" if="sign-preloader-notemplate" unless="preloader-app">
		        <echo message="-deploy-app-sign-preloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign-preloader/>
		        <deploy-deploy/>
		    </target>
		    <target name="-deploy-app-sign-blob-preloader-notemplate" depends="-check-sign" if="sign-blob-preloader-notemplate" unless="preloader-app">
		        <echo message="-deploy-app-sign-blob-preloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign-blob-preloader/>
		        <deploy-deploy/>
		    </target>
		
		    <!-- project without preloader -->
		    <!-- html template -->
		    <target name="-deploy-app-sign-nopreloader-template" depends="-check-sign" if="sign-nopreloader-template" unless="preloader-app">
		        <echo message="-deploy-app-sign-nopreloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign/>
		        <deploy-process-template/>
		        <deploy-deploy/>
		    </target>
		    <target name="-deploy-app-sign-blob-nopreloader-template" depends="-check-sign" if="sign-blob-nopreloader-template" unless="preloader-app">
		        <echo message="-deploy-app-sign-blob-nopreloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign-blob/>
		        <deploy-process-template/>
		        <deploy-deploy/>
		    </target>
		
		    <!-- project with preloader -->
		    <!-- html template -->
		    <target name="-deploy-app-sign-preloader-template" depends="-check-sign" if="sign-preloader-template" unless="preloader-app">
		        <echo message="-deploy-app-sign-preloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign-preloader/>
		        <deploy-process-template/>
		        <deploy-deploy/>
		    </target>
		    <target name="-deploy-app-sign-blob-preloader-template" depends="-check-sign" if="sign-blob-preloader-template" unless="preloader-app">
		        <echo message="-deploy-app-sign-blob-preloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign-blob-preloader/>
		        <deploy-process-template/>
		        <deploy-deploy/>
		    </target>
		
		    <!-- project without preloader -->
		    <!-- no html template -->
		    <!-- FX in Swing app -->
		    <target name="-deploy-app-sign-nopreloader-notemplate-swing" depends="-check-sign" if="sign-nopreloader-notemplate-swing" unless="preloader-app-no-workaround">
		        <echo message="-deploy-app-sign-nopreloader-notemplate-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign/>
		        <deploy-deploy-swing/>
		    </target>
		    <target name="-deploy-app-sign-blob-nopreloader-notemplate-swing" depends="-check-sign" if="sign-blob-nopreloader-notemplate-swing" unless="preloader-app-no-workaround">
		        <echo message="-deploy-app-sign-blob-nopreloader-notemplate-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign-blob/>
		        <deploy-deploy-swing/>
		    </target>
		
		    <!-- project without preloader -->
		    <!-- html template -->
		    <!-- FX in Swing app -->
		    <target name="-deploy-app-sign-nopreloader-template-swing" depends="-check-sign" if="sign-nopreloader-template-swing" unless="preloader-app-no-workaround">
		        <echo message="-deploy-app-sign-nopreloader-template-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign/>
		        <deploy-process-template/>
		        <deploy-deploy-swing/>
		    </target>
		    <target name="-deploy-app-sign-blob-nopreloader-template-swing" depends="-check-sign" if="sign-blob-nopreloader-template-swing" unless="preloader-app-no-workaround">
		        <echo message="-deploy-app-sign-blob-nopreloader-template-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-sign-blob/>
		        <deploy-process-template/>
		        <deploy-deploy-swing/>
		    </target>
		
		
		    <!-- NO SIGNING -->
		
		    <!-- project without preloader -->
		    <!-- no html template -->
		    <target name="-deploy-app-nosign-nopreloader-notemplate" depends="-check-nosign" if="nosign-nopreloader-notemplate" unless="preloader-app">
		        <echo message="-deploy-app-nosign-nopreloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-deploy/>
		    </target>
		
		    <!-- project with preloader -->
		    <!-- no html template -->
		    <target name="-deploy-app-nosign-preloader-notemplate" depends="-check-nosign" if="nosign-preloader-notemplate" unless="preloader-app">
		        <echo message="-deploy-app-nosign-preloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-deploy/>
		    </target>
		
		    <!-- project without preloader -->
		    <!-- html template -->
		    <target name="-deploy-app-nosign-nopreloader-template" depends="-check-nosign" if="nosign-nopreloader-template" unless="preloader-app">
		        <echo message="-deploy-app-nosign-nopreloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-process-template/>
		        <deploy-deploy/>
		    </target>
		
		    <!-- project with preloader -->
		    <!-- html template -->
		    <target name="-deploy-app-nosign-preloader-template" depends="-check-nosign" if="nosign-preloader-template" unless="preloader-app">
		        <echo message="-deploy-app-nosign-preloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-process-template/>
		        <deploy-deploy/>
		    </target>
		
		    <!-- project without preloader -->
		    <!-- no html template -->
		    <!-- FX in Swing app -->
		    <target name="-deploy-app-nosign-nopreloader-notemplate-swing" depends="-check-nosign" if="nosign-nopreloader-notemplate-swing" unless="preloader-app-no-workaround">
		        <echo message="-deploy-app-nosign-nopreloader-notemplate-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-deploy-swing/>
		    </target>
		
		    <!-- project without preloader -->
		    <!-- html template -->
		    <!-- FX in Swing app -->
		    <target name="-deploy-app-nosign-nopreloader-template-swing" depends="-check-nosign" if="nosign-nopreloader-template-swing" unless="preloader-app-no-workaround">
		        <echo message="-deploy-app-nosign-nopreloader-template-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <deploy-jar/>
		        <deploy-process-template/>
		        <deploy-deploy-swing/>
		    </target>
		
		
		    <!-- FALLBACK (NO JAVASCRIPT) TARGETS WITH SIGNING -->
		
		    <target name="-check-fallback-sign-deploy-swing-possible" depends="-check-sign">
		        <local name="fail-deploy-swing-possible"/>
		        <condition property="fail-deploy-swing-possible">
		            <and>
		                <or>
		                    <isset property="sign-nopreloader-notemplate-swing"/>
		                    <isset property="sign-nopreloader-template-swing"/>
		                </or>
		                <not><isset property="have-fx-ant-api-1.2"/></not>
		            </and>
		        </condition>
		        <fail message="Error: JavaFX SDK version 2.2 or newer is needed to deploy FX-in-Swing on JDK without JavaScript support." 
		              if="fail-deploy-swing-possible"/>
		    </target>
		    
		    <!-- FALLBACK project without preloader -->
		    <!-- FALLBACK no html template -->
		    <target name="-fallback-deploy-app-sign-nopreloader-notemplate" depends="-check-sign" if="sign-nopreloader-notemplate" unless="preloader-app">
		        <echo message="-fallback-deploy-app-sign-nopreloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <deploy-sign/>
		        <fallback-deploy-deploy/>
		    </target>
		    <target name="-fallback-deploy-app-sign-blob-nopreloader-notemplate" depends="-check-sign" if="sign-blob-nopreloader-notemplate" unless="preloader-app">
		        <echo message="-fallback-deploy-app-sign-blob-nopreloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <deploy-sign-blob/>
		        <fallback-deploy-deploy/>
		    </target>
		
		    <!-- FALLBACK project with preloader -->
		    <!-- FALLBACK no html template -->
		    <target name="-fallback-deploy-app-sign-preloader-notemplate" depends="-check-sign" if="sign-preloader-notemplate" unless="preloader-app">
		        <echo message="-fallback-deploy-app-sign-preloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-preloader/>
		        <fallback-deploy-resources-preloader/>
		        <fallback-deploy-jar/>
		        <deploy-sign-preloader/>
		        <fallback-deploy-deploy/>
		    </target>
		    <target name="-fallback-deploy-app-sign-blob-preloader-notemplate" depends="-check-sign" if="sign-blob-preloader-notemplate" unless="preloader-app">
		        <echo message="-fallback-deploy-app-sign-blob-preloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-preloader/>
		        <fallback-deploy-resources-preloader/>
		        <fallback-deploy-jar/>
		        <deploy-sign-blob-preloader/>
		        <fallback-deploy-deploy/>
		    </target>
		
		    <!-- FALLBACK project without preloader -->
		    <!-- FALLBACK html template -->
		    <target name="-fallback-deploy-app-sign-nopreloader-template" depends="-check-sign" if="sign-nopreloader-template" unless="preloader-app">
		        <echo message="-fallback-deploy-app-sign-nopreloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <deploy-sign/>
		        <fallback-deploy-deploy-template/>
		    </target>
		    <target name="-fallback-deploy-app-sign-blob-nopreloader-template" depends="-check-sign" if="sign-blob-nopreloader-template" unless="preloader-app">
		        <echo message="-fallback-deploy-app-sign-blob-nopreloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <deploy-sign-blob/>
		        <fallback-deploy-deploy-template/>
		    </target>
		
		    <!-- FALLBACK project with preloader -->
		    <!-- FALLBACK html template -->
		    <target name="-fallback-deploy-app-sign-preloader-template" depends="-check-sign" if="sign-preloader-template" unless="preloader-app">
		        <echo message="-fallback-deploy-app-sign-preloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-preloader/>
		        <fallback-deploy-resources-preloader/>
		        <fallback-deploy-jar/>
		        <deploy-sign-preloader/>
		        <fallback-deploy-deploy-template/>
		    </target>
		    <target name="-fallback-deploy-app-sign-blob-preloader-template" depends="-check-sign" if="sign-blob-preloader-template" unless="preloader-app">
		        <echo message="-fallback-deploy-app-sign-blob-preloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-preloader/>
		        <fallback-deploy-resources-preloader/>
		        <fallback-deploy-jar/>
		        <deploy-sign-blob-preloader/>
		        <fallback-deploy-deploy-template/>
		    </target>
		
		    <!-- FALLBACK project without preloader -->
		    <!-- FALLBACK no html template -->
		    <!-- FALLBACK FX in Swing app -->
		    <target name="-fallback-deploy-app-sign-nopreloader-notemplate-swing" depends="-check-fallback-sign-deploy-swing-possible" if="sign-nopreloader-notemplate-swing" unless="preloader-app-no-workaround">
		        <echo message="-fallback-deploy-app-sign-nopreloader-notemplate-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-swing/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <deploy-sign/>
		        <fallback-deploy-deploy/>
		    </target>
		    <target name="-fallback-deploy-app-sign-blob-nopreloader-notemplate-swing" depends="-check-fallback-sign-deploy-swing-possible" if="sign-nopreloader-notemplate-swing" unless="preloader-app-no-workaround">
		        <echo message="-fallback-deploy-app-sign-blob-nopreloader-notemplate-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-swing/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <deploy-sign-blob/>
		        <fallback-deploy-deploy/>
		    </target>
		
		    <!-- FALLBACK project without preloader -->
		    <!-- FALLBACK html template -->
		    <!-- FALLBACK FX in Swing app -->
		    <target name="-fallback-deploy-app-sign-nopreloader-template-swing" depends="-check-fallback-sign-deploy-swing-possible" if="sign-nopreloader-template-swing" unless="preloader-app-no-workaround">
		        <echo message="-fallback-deploy-app-sign-nopreloader-template-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-swing/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <deploy-sign/>
		        <fallback-deploy-deploy-template/>
		    </target>
		    <target name="-fallback-deploy-app-sign-blob-nopreloader-template-swing" depends="-check-fallback-sign-deploy-swing-possible" if="sign-nopreloader-template-swing" unless="preloader-app-no-workaround">
		        <echo message="-fallback-deploy-app-sign-blob-nopreloader-template-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-swing/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <deploy-sign-blob/>
		        <fallback-deploy-deploy-template/>
		    </target>
		
		
		    <!-- FALLBACK (NO JAVASCRIPT) TARGETS NO SIGNING -->
		
		    <target name="-check-fallback-nosign-deploy-swing-possible" depends="-check-nosign">
		        <local name="fail-deploy-swing-possible"/>
		        <condition property="fail-deploy-swing-possible">
		            <and>
		                <or>
		                    <isset property="nosign-nopreloader-notemplate-swing"/>
		                    <isset property="nosign-nopreloader-template-swing"/>
		                </or>
		                <not><isset property="have-fx-ant-api-1.2"/></not>
		            </and>
		        </condition>
		        <fail message="Error: JavaFX SDK version 2.2 or newer is needed to deploy FX-in-Swing on JDK without JavaScript support." 
		              if="fail-deploy-swing-possible"/>
		    </target>
		
		    <!-- FALLBACK project without preloader -->
		    <!-- FALLBACK no html template -->
		    <target name="-fallback-deploy-app-nosign-nopreloader-notemplate" depends="-check-nosign" if="nosign-nopreloader-notemplate" unless="preloader-app">
		        <echo message="-fallback-deploy-app-nosign-nopreloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <fallback-deploy-deploy/>
		    </target>
		
		    <!-- FALLBACK project with preloader -->
		    <!-- FALLBACK no html template -->
		    <target name="-fallback-deploy-app-nosign-preloader-notemplate" depends="-check-nosign" if="nosign-preloader-notemplate" unless="preloader-app">
		        <echo message="-fallback-deploy-app-nosign-preloader-notemplate" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-preloader/>
		        <fallback-deploy-resources-preloader/>
		        <fallback-deploy-jar/>
		        <fallback-deploy-deploy/>
		    </target>
		
		    <!-- FALLBACK project without preloader -->
		    <!-- FALLBACK html template -->
		    <target name="-fallback-deploy-app-nosign-nopreloader-template" depends="-check-nosign" if="nosign-nopreloader-template" unless="preloader-app">
		        <echo message="-fallback-deploy-app-nosign-nopreloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <fallback-deploy-deploy-template/>
		    </target>
		
		    <!-- FALLBACK project with preloader -->
		    <!-- FALLBACK html template -->
		    <target name="-fallback-deploy-app-nosign-preloader-template" depends="-check-nosign" if="nosign-preloader-template" unless="preloader-app">
		        <echo message="-fallback-deploy-app-nosign-preloader-template" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-preloader/>
		        <fallback-deploy-resources-preloader/>
		        <fallback-deploy-jar/>
		        <fallback-deploy-deploy-template/>
		    </target>
		
		    <!-- FALLBACK project without preloader -->
		    <!-- FALLBACK no html template -->
		    <!-- FALLBACK FX in Swing app -->
		    <target name="-fallback-deploy-app-nosign-nopreloader-notemplate-swing" depends="-check-fallback-nosign-deploy-swing-possible" if="nosign-nopreloader-notemplate-swing" unless="preloader-app-no-workaround">
		        <echo message="-fallback-deploy-app-nosign-nopreloader-notemplate-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-swing/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <fallback-deploy-deploy/>
		    </target>
		
		    <!-- FALLBACK project without preloader -->
		    <!-- FALLBACK html template -->
		    <!-- FALLBACK FX in Swing app -->
		    <target name="-fallback-deploy-app-nosign-nopreloader-template-swing" depends="-check-fallback-nosign-deploy-swing-possible" if="nosign-nopreloader-template-swing" unless="preloader-app-no-workaround">
		        <echo message="-fallback-deploy-app-nosign-nopreloader-template-swing" level="verbose"/>
		        <deploy-defines/>
		        <deploy-preprocess/>
		        <fallback-deploy-application-def-swing/>
		        <fallback-deploy-resources/>
		        <fallback-deploy-jar/>
		        <fallback-deploy-deploy-template/>
		    </target>
		
		
		    <!-- Project Build Targets -->
		
		    <target name="jfx-build" depends="-jfx-do-compile, -jfx-do-jar, -jfx-do-post-jar"/>
		    <target name="jfx-build-noscript" depends="-set-fallback-no-javascript, -jfx-do-compile, -jfx-do-jar, -jfx-do-post-jar"/>
		    
		    <target name="jfx-rebuild" depends="clean, -jfx-do-compile, -jfx-do-jar, -jfx-do-post-jar"/>
		    <target name="jfx-rebuild-noscript" depends="-set-fallback-no-javascript, clean, -jfx-do-compile, -jfx-do-jar, -jfx-do-post-jar"/>
		
		    <target name="jfx-build-native" depends="-set-do-build-native-package, -check-ant-jre-supports-native-packaging, -check-native-packager-external-tools, jfx-rebuild"/>
		    <target name="jfx-build-native-noscript" depends="-set-do-build-native-package, -check-ant-jre-supports-native-packaging, -check-native-packager-external-tools, jfx-rebuild-noscript"/>
		
		    <target name="build-native">
		        <property name="javafx.native.bundling.type" value="${native.bundling.type}"/>
		        <antcall target="jfx-build-native"/>
		    </target>
		    <target name="build-native-noscript">
		        <property name="javafx.native.bundling.type" value="${native.bundling.type}"/>        
		        <antcall target="jfx-build-native-noscript"/>
		    </target>
		    
		    <target name="-check-do-jar">
		        <condition property="do-jar-false">
		            <and>
		                <isset property="do.jar"/>
		                <equals arg1="${do.jar}" arg2="false"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-fallback-no-javascript">
		        <property name="fallback.no.javascript" value="true"/>
		        <echo message="Warning: Using fallback build infrastructure due to default JDK missing JavaScript support."/>
		    </target>
		    <target name="-jfx-do-compile" depends="-check-do-jar" if="do-jar-false">
		        <antcall target="compile"/>
		    </target>
		    <target name="-jfx-do-jar" depends="-check-do-jar" unless="do-jar-false">
		        <antcall target="jar"/>
		    </target>
		    <target name="-jfx-do-post-jar" depends="-init-check,-check-project" if="preloader-app">
		        <!-- Preloaders are created using SE copylibs task that creates readme file relevant for SE only -->
		        <delete file="${basedir}${file.separator}${dist.dir}${file.separator}README.TXT"/>
		    </target>
		    
		    <target name="-set-do-build-native-package">
		        <property name="do.build.native.package" value="true"/>
		        <echo message="do.build.native.package = ${do.build.native.package}" level="verbose"/>
		    </target>
		    <target name="-check-ant-jre-supports-native-packaging" depends="-check-ant-jre-version">
		        <fail message="Error:${line.separator}JavaFX native packager requires NetBeans to run on JDK 1.7u6 or later !" if="have-ant-jre-pre7u6"/>
		    </target>
		    
		    <target name="-call-pre-jfx-native" if="do.build.native.package">
		        <antcall target="-pre-jfx-native"/>
		    </target>
		    <target name="-call-post-jfx-native" if="do.build.native.package">
		        <antcall target="-post-jfx-native"/>
		    </target>
		
		    <target name="-check-native-bundling-type" depends="-check-operating-system" if="do.build.native.package">
		        <condition property="need.Inno.presence">
		            <and>
		                <isset property="running.on.windows"/>
		                <isset property="javafx.native.bundling.type"/>
		                <or>
		                    <equals arg1="${javafx.native.bundling.type}" arg2="all" casesensitive="false"/>
		                    <equals arg1="${javafx.native.bundling.type}" arg2="installer" casesensitive="false"/>
		                    <equals arg1="${javafx.native.bundling.type}" arg2="exe" casesensitive="false"/>
		                </or>
		            </and>
		        </condition>
		        <condition property="need.WiX.presence">
		            <and>
		                <isset property="running.on.windows"/>
		                <isset property="javafx.native.bundling.type"/>
		                <or>
		                    <equals arg1="${javafx.native.bundling.type}" arg2="all" casesensitive="false"/>
		                    <equals arg1="${javafx.native.bundling.type}" arg2="installer" casesensitive="false"/>
		                    <equals arg1="${javafx.native.bundling.type}" arg2="msi" casesensitive="false"/>
		                </or>
		            </and>
		        </condition>
		        <condition property="need.dpkg.presence">
		            <and>
		                <isset property="running.on.unix"/>
		                <isset property="javafx.native.bundling.type"/>
		                <or>
		                    <equals arg1="${javafx.native.bundling.type}" arg2="deb" casesensitive="false"/>
		                </or>
		            </and>
		        </condition>
		        <condition property="need.rpmbuild.presence">
		            <and>
		                <isset property="running.on.unix"/>
		                <isset property="javafx.native.bundling.type"/>
		                <or>
		                    <equals arg1="${javafx.native.bundling.type}" arg2="rpm" casesensitive="false"/>
		                </or>
		            </and>
		        </condition>
		        <echo message="need.Inno.presence:${need.Inno.presence}" level="verbose"/>
		        <echo message="need.WiX.presence:${need.WiX.presence}" level="verbose"/>
		        <echo message="need.dpkg.presence:${need.dpkg.presence}" level="verbose"/>
		        <echo message="need.rpmbuild.presence:${need.rpmbuild.presence}" level="verbose"/>
		    </target>
		    <target name="-check-Inno-presence" depends="-check-native-bundling-type" if="need.Inno.presence">
		        <local name="exec-output"/>
		        <local name="exec-error"/>
		        <local name="exec-result"/>
		        <exec executable="iscc" outputproperty="exec-output" failifexecutionfails="false" errorproperty="exec-error" resultproperty="exec-result"/>
		        <echo message="exec-output:${exec-output}" level="verbose"/>
		        <echo message="exec-error:${exec-error}" level="verbose"/>
		        <echo message="exec-result:${exec-result}" level="verbose"/>
		        <condition property="missing.Inno">
		            <not><and>
		                <contains string="${exec-output}" substring="Inno Setup"/>
		                <not><contains string="${exec-output}" substring="Inno Setup 1"/></not>
		                <not><contains string="${exec-output}" substring="Inno Setup 2"/></not>
		                <not><contains string="${exec-output}" substring="Inno Setup 3"/></not>
		                <not><contains string="${exec-output}" substring="Inno Setup 4"/></not>
		            </and></not>
		        </condition>
		    </target>
		    <target name="-check-WiX-presence" depends="-check-native-bundling-type" if="need.WiX.presence">
		        <local name="exec-output"/>
		        <local name="exec-error"/>
		        <local name="exec-result"/>
		        <exec executable="candle" outputproperty="exec-output" failifexecutionfails="false" errorproperty="exec-error" resultproperty="exec-result">
		            <arg value="-?"/>
		        </exec>
		        <echo message="exec-output:${exec-output}" level="verbose"/>
		        <echo message="exec-error:${exec-error}" level="verbose"/>
		        <echo message="exec-result:${exec-result}" level="verbose"/>
		        <condition property="missing.WiX">
		            <not>
		                <matches string="${exec-output}" pattern="windows\s+installer\s+xml\s+(toolset\s+)?compiler\s+version\s+3.*" casesensitive="false"/>
		            </not>
		        </condition>
		    </target>
		    <target name="-check-dpkg-presence" depends="-check-native-bundling-type" if="need.dpkg.presence">
		        <local name="exec.which.dpkg.result"/>
		        <local name="exec.which.dpkg.output"/>
		        <exec executable="command" failifexecutionfails="false" failonerror="false" resultproperty="exec.which.dpkg.result" outputproperty="exec.which.dpkg.output">
		            <arg line="-v dpkg"/>
		        </exec>
		        <condition property="missing.dpkg">
		            <not><and>
		                <isset property="exec.which.dpkg.result"/>
		                <equals arg1="${exec.which.dpkg.result}" arg2="0"/>
		                <isset property="exec.which.dpkg.output"/>
		                <not><equals arg1="${exec.which.dpkg.output}" arg2=""/></not>
		            </and></not>
		        </condition>
		    </target>
		    <target name="-check-rpmbuild-presence" depends="-check-native-bundling-type" if="need.rpmbuild.presence">
		        <local name="exec.which.rpmbuild.result"/>
		        <local name="exec.which.rpmbuild.output"/>
		        <exec executable="command" failifexecutionfails="false" failonerror="false" resultproperty="exec.which.rpmbuild.result" outputproperty="exec.which.rpmbuild.output">
		            <arg line="-v rpmbuild"/>
		        </exec>
		        <condition property="missing.rpmbuild">
		            <not><and>
		                <isset property="exec.which.rpmbuild.result"/>
		                <equals arg1="${exec.which.rpmbuild.result}" arg2="0"/>
		                <isset property="exec.which.rpmbuild.output"/>
		                <not><equals arg1="${exec.which.rpmbuild.output}" arg2=""/></not>
		            </and></not>
		        </condition>
		    </target>
		    <target name="-check-native-packager-external-tools" depends="-check-Inno-presence, -check-WiX-presence, -check-dpkg-presence, -check-rpmbuild-presence">
		        <property name="missing.Inno.message" value="JavaFX native packager requires external Inno Setup 5+ tools installed and included on PATH to create EXE installer. See http://www.jrsoftware.org/"/>
		        <property name="missing.WiX.message" value="JavaFX native packager requires external WiX 3.0+ tools installed and included on PATH to create MSI installer. See http://wix.sourceforge.net/"/>
		        <property name="missing.dpkg.message" value="JavaFX native packager requires Debian Packager tools to create DEB package, but dpkg could not be found."/>
		        <property name="missing.rpmbuild.message" value="JavaFX native packager requires RPMBuild to create RPM package, but rpmbuild could not be found."/>
		        <condition property="missing.Inno.WiX">
		            <and>
		                <isset property="missing.Inno"/>
		                <isset property="missing.WiX"/>
		            </and>
		        </condition>
		        <fail message="Error:${line.separator}${missing.Inno.message}${line.separator}${missing.WiX.message}" if="missing.Inno.WiX"/>
		        <fail message="Error:${line.separator}${missing.Inno.message}" if="missing.Inno"/>
		        <fail message="Error:${line.separator}${missing.WiX.message}" if="missing.WiX"/>
		        <fail message="Error:${line.separator}${missing.dpkg.message}" if="missing.dpkg"/>
		        <fail message="Error:${line.separator}${missing.rpmbuild.message}" if="missing.rpmbuild"/>
		    </target>
		
		    <!-- Project Run Support -->
		
		    <target name="-warn-of-preloader" depends="-check-project" if="preloader-app-no-workaround">
		        <fail message="Error:${line.separator}JavaFX 2 Preloader Project can not be executed directly.${line.separator}Please execute instead a JavaFX Application that uses the Preloader."/>
		    </target>
		    
		    <target name="-mark-project-state-running">
		        <property name="project.state.running" value="true"/>
		        <echo message="project.state.running = ${project.state.running}" level="verbose"/>
		    </target>
		    <target name="-mark-project-state-debugging">
		        <property name="project.state.debugging" value="true"/>
		        <echo message="project.state.debugging = ${project.state.debugging}" level="verbose"/>
		    </target>
		    <target name="-mark-project-state-debugging-in-browser" depends="-mark-project-state-debugging">
		        <property name="project.state.debugging.in.browser" value="true"/>
		        <echo message="project.state.debugging.in.browser = ${project.state.debugging.in.browser}" level="verbose"/>
		    </target>
		    <target name="-mark-project-state-profiling">
		        <property name="project.state.profiling" value="true"/>
		        <echo message="project.state.profiling = ${project.state.profiling}" level="verbose"/>
		    </target>
		    <target name="-mark-project-needs-jnlp">
		        <property name="project.needs.jnlp" value="true"/>
		        <echo message="project.needs.jnlp = ${project.needs.jnlp}" level="verbose"/>
		    </target>
		    
		    <!-- set property javafx.disable.concurrent.runs=true to disable runs from temporary directory -->
		    <target name="-check-concurrent-runs">
		        <condition property="disable-concurrent-runs">
		            <and>
		                <isset property="javafx.disable.concurrent.runs"/>
		                <equals arg1="${javafx.disable.concurrent.runs}" arg2="true" trim="true"/>
		            </and>
		        </condition>
		        <condition property="temp.run.jar" value="${jfx.deployment.dir}${file.separator}${jfx.deployment.jar}">
		            <isset property="disable-concurrent-runs"/>
		        </condition>
		        <condition property="temp.run.jnlp" value="${jfx.deployment.jnlp}">
		            <isset property="disable-concurrent-runs"/>
		        </condition>
		        <condition property="temp.run.html" value="${jfx.deployment.html}">
		            <isset property="disable-concurrent-runs"/>
		        </condition>
		    </target>
		    <target name="-create-temp-run-dir" depends="-check-concurrent-runs" unless="disable-concurrent-runs">
		        <echo message="Creating temp run dir" level="verbose"/>
		        <tempfile property="temp.run.dir" destDir="${basedir}${file.separator}${dist.dir}${file.separator}" prefix="run"/>
		        <echo message="temp.run.dir = ${temp.run.dir}" level="verbose"/>
		        <copy todir="${temp.run.dir}" includeemptydirs="true" overwrite="true">
		            <fileset dir="${basedir}${file.separator}${dist.dir}">
		                <exclude name="**${file.separator}bundles${file.separator}**"/>
		                <exclude name="**${file.separator}run*${file.separator}**"/>
		            </fileset>
		        </copy>        
		        <property name="temp.run.jar" value="${temp.run.dir}${file.separator}${jfx.deployment.jar}"/>
		        <basename property="jfx.deployment.base" file="${jfx.deployment.jar}" suffix=".jar"/>
		        <property name="temp.run.jnlp" value="${temp.run.dir}${file.separator}${jfx.deployment.base}.jnlp"/>
		        <property name="temp.run.html" value="${temp.run.dir}${file.separator}${jfx.deployment.base}.html"/>
		    </target>
		    <target name="-remove-temp-run-dir" if="temp.run.dir">
		        <echo message="Removing temp run dir" level="verbose"/>
		        <delete dir="${temp.run.dir}" quiet="true" failonerror="false"/>
		    </target>
		    <target depends="init,compile,jar,-create-temp-run-dir" description="Run JavaFX project standalone." name="jfx-project-run">
		        <echo message="Executing ${temp.run.jar} using platform ${platform.java}"/>
		        <property name="run.jvmargs" value=""/>
		        <property name="run.jvmargs.ide" value=""/>        
		        <java jar="${temp.run.jar}" dir="${work.dir}" fork="true" jvm="${platform.java}">
		            <jvmarg line="${endorsed.classpath.cmd.line.arg}"/>
		            <jvmarg value="-Dfile.encoding=${runtime.encoding}"/>
		            <redirector errorencoding="${runtime.encoding}" inputencoding="${runtime.encoding}" outputencoding="${runtime.encoding}"/>
		            <jvmarg line="${run.jvmargs}"/>
		            <jvmarg line="${run.jvmargs.ide}"/>
		            <classpath>
		                <path path="${temp.run.jar}:${javac.classpath}"/>
		            </classpath>
		            <arg line="${application.args}"/>
		            <syspropertyset>
		                <propertyref prefix="run-sys-prop."/>
		                <mapper from="run-sys-prop.*" to="*" type="glob"/>
		            </syspropertyset>
		        </java>
		        <antcall target="-remove-temp-run-dir"/>
		    </target>
		    <target depends="init,compile,jar,-create-temp-run-dir,-debug-start-debugger" description="Debug JavaFX project standalone." name="jfx-project-debug">
		        <echo message="Executing ${temp.run.jar} using platform ${platform.java}"/>
		        <property name="run.jvmargs" value=""/>
		        <property name="run.jvmargs.ide" value=""/>        
		        <java jar="${temp.run.jar}" dir="${work.dir}" fork="true" jvm="${platform.java}">
		            <jvmarg line="${endorsed.classpath.cmd.line.arg}"/>
		            <jvmarg line="${debug-args-line}"/>
		            <jvmarg value="-Xrunjdwp:transport=${debug-transport},address=${jpda.address}"/>
		            <jvmarg value="-Dglass.disableGrab=true"/>
		            <jvmarg value="-Dfile.encoding=${runtime.encoding}"/>
		            <redirector errorencoding="${runtime.encoding}" inputencoding="${runtime.encoding}" outputencoding="${runtime.encoding}"/>
		            <jvmarg line="${run.jvmargs}"/>
		            <jvmarg line="${run.jvmargs.ide}"/>
		            <classpath>
		                <path path="${temp.run.jar}:${javac.classpath}"/>
		            </classpath>
		            <arg line="${application.args}"/>
		            <syspropertyset>
		                <propertyref prefix="run-sys-prop."/>
		                <mapper from="run-sys-prop.*" to="*" type="glob"/>
		            </syspropertyset>
		        </java>
		        <antcall target="-remove-temp-run-dir"/>
		    </target>
		
		
		    <!-- Running/Debugging/Profiling Standalone -->
		
		    <target name="jfxsa-run" depends="-mark-project-state-running,-clean-if-config-changed,-check-jfx-runtime,-warn-of-preloader,jfx-project-run"/>
		    <target name="jfxsa-run-noscript" depends="-set-fallback-no-javascript, jfxsa-run"/>
		
		    <target name="jfxsa-debug" depends="-mark-project-state-debugging,-clean-if-config-changed,jar,-check-jfx-runtime,-warn-of-preloader,jfx-project-debug"/>
		    <target name="jfxsa-debug-noscript" depends="-set-fallback-no-javascript, jfxsa-debug"/>
		    
		    <target name="jfxsa-profile" depends="-mark-project-state-profiling,-check-jfx-runtime,-warn-of-preloader,jfx-project-profile"/>
		    <target name="jfxsa-profile-noscript" depends="-set-fallback-no-javascript, jfxsa-profile"/>
		
		    <target name="-check-clean-if-config-changed" depends="-init-project">
		        <deploy-defines/>
		        <uptodate property="jfx.deployment.jar.newer.than.nbproject" targetfile="${jfx.deployment.dir}${file.separator}${jfx.deployment.jar}" >
		            <srcfiles dir="${basedir}${file.separator}nbproject" includes="**${file.separator}*"/>
		        </uptodate>
		        <echo message="jfx.deployment.jar.newer.than.nbproject = ${jfx.deployment.jar.newer.than.nbproject}" level="verbose"/>
		        <available file="${jfx.deployment.dir}${file.separator}${jfx.deployment.jar}" type="file" property="jfx.deployment.jar.exists"/>
		        <condition property="request.clean.due.to.config.change">
		            <and>
		                <isset property="jfx.deployment.jar.exists"/>
		                <not><isset property="jfx.deployment.jar.newer.than.nbproject"/></not>
		            </and>
		        </condition>
		    </target>
		    <target name="-clean-if-config-changed" depends="-check-clean-if-config-changed" if="request.clean.due.to.config.change">
		        <echo message="Config change detected. Invoking clean." level="verbose"/>
		        <antcall target="clean"/>
		    </target>
		    
		    <target depends="-profile-check-1,-profile-pre72" description="Profile a project in the IDE." if="profiler.configured" name="jfx-project-profile" unless="profiler.info.jvmargs.agent">
		        <startprofiler/>
		        <antcall target="jfxsa-run"/>
		    </target>
		
		    <!-- Shared Debugging init -->
		
		    <target name="-init-debug-args">
		        <property name="version-output" value="java version &quot;${ant.java.version}"/>
		        <condition property="have-jdk-older-than-1.4">
		            <or>
		                <contains string="${version-output}" substring="java version &quot;1.0"/>
		                <contains string="${version-output}" substring="java version &quot;1.1"/>
		                <contains string="${version-output}" substring="java version &quot;1.2"/>
		                <contains string="${version-output}" substring="java version &quot;1.3"/>
		            </or>
		        </condition>
		        <condition else="-Xdebug" property="debug-args-line" value="-Xdebug -Xnoagent -Djava.compiler=none">
		            <istrue value="${have-jdk-older-than-1.4}"/>
		        </condition>
		        <condition else="dt_socket" property="debug-transport-by-os" value="dt_shmem">
		            <os family="windows"/>
		        </condition>
		        <condition else="${debug-transport-by-os}" property="debug-transport" value="${debug.transport}">
		            <isset property="debug.transport"/>
		        </condition>
		    </target>
		
		
		    <!-- Running/Debugging/Profiling as WebStart -->
		
		    <target name="-check-jnlp-file-fx" depends="-swing-api-check" unless="fx-in-swing-app-workaround">
		        <basename property="jfx.deployment.base" file="${jfx.deployment.jar}" suffix=".jar"/>
		        <property name="jfx.deployment.jnlp" location="${jfx.deployment.dir}${file.separator}${jfx.deployment.base}.jnlp"/>
		    </target>
		    <target name="-check-jnlp-file-swing" depends="-swing-api-check" if="fx-in-swing-app-workaround">
		        <basename property="jfx.deployment.base" file="${jfx.deployment.jar}" suffix=".jar"/>
		        <property name="jfx.deployment.jnlp" location="${jfx.deployment.dir}${file.separator}${jfx.deployment.base}_application.jnlp"/>
		    </target>
		    <target name="-check-jnlp-file" depends="-check-jnlp-file-fx,-check-jnlp-file-swing">
		        <condition property="jnlp-file-exists">
		            <available file="${jfx.deployment.jnlp}"/>
		        </condition>
		        <condition property="jnlp-file-exists+netbeans.home">
		            <and>
		                <isset property="jnlp-file-exists"/>
		                <isset property="netbeans.home"/>
		            </and>
		        </condition>
		    </target>
		
		    <target name="-resolve-jnlp-file" depends="-check-jnlp-file" unless="jnlp-file-exists">
		        <antcall target="jfx-deployment"/>
		        <antcall target="-check-jnlp-file"/>
		    </target>
		
		    <!-- set property javafx.enable.concurrent.external.runs=true to enable multiple runs of the same WebStart or Run-in-Browser project -->
		    <target name="-check-concurrent-jnlp-runs" depends="-resolve-jnlp-file">
		        <condition property="disable-concurrent-runs">
		            <not>
		                <and>
		                    <isset property="javafx.enable.concurrent.external.runs"/>
		                    <equals arg1="${javafx.enable.concurrent.external.runs}" arg2="true" trim="true"/>
		                </and>
		            </not>
		        </condition>
		        <condition property="temp.run.jnlp" value="${jfx.deployment.jnlp}">
		            <isset property="disable-concurrent-runs"/>
		        </condition>
		    </target>
		    <target name="-warn-concurrent-jnlp-runs" unless="disable-concurrent-runs">
		        <echo message="Note: Concurrent Run as WebStart enabled.${line.separator}Temporary directory ${temp.run.dir}${line.separator}will remain unused when WebStart execution has finished. Use project Clean to delete unused directories."/>
		    </target>
		
		    <target name="jfxws-run" if="jnlp-file-exists" depends="-mark-project-state-running,-clean-if-config-changed,-mark-project-needs-jnlp,-check-jdk-7u4or5-mac,jar,
		            -check-jfx-webstart,-resolve-jnlp-file,-check-jfx-runtime,-check-concurrent-jnlp-runs,-create-temp-run-dir,-warn-insufficient-signing" 
		            description="Start JavaFX javaws execution">
		        <echo message="Executing ${temp.run.jnlp} using ${active.webstart.executable}"/>
		        <exec executable="${active.webstart.executable}">
		            <arg file="${temp.run.jnlp}"/>
		        </exec>
		        <antcall target="-warn-concurrent-jnlp-runs"/>
		    </target>
		    
		    <target name="jfxws-debug" if="jnlp-file-exists+netbeans.home" depends="-mark-project-state-debugging,-clean-if-config-changed,-mark-project-needs-jnlp,
		            -check-jdk-7u4or5-mac,jar,-check-jfx-webstart,-resolve-jnlp-file,-check-jfx-runtime,-warn-insufficient-signing,
		            -debug-start-debugger,-debug-javaws-debuggee" description="Debug JavaFX javaws project in IDE"/>
		        
		    <target name="-debug-javaws-debuggee" depends="-init-debug-args">
		        <echo message="Executing ${jfx.deployment.jnlp} in debug mode using ${active.webstart.executable}"/>
		        <exec executable="${active.webstart.executable}">
		            <env key="JAVAWS_VM_ARGS" value="${debug-args-line} -Xrunjdwp:transport=${debug-transport},address=${jpda.address} -Dglass.disableGrab=true"/>
		            <arg value="-wait"/>
		            <arg file="${jfx.deployment.jnlp}"/>
		        </exec>
		    </target>
		    
		    <target name="-profile-check-1">
		        <property name="run.jvmargs.ide" value=""/>        
		        <condition property="profiler.configured">
		            <or>
		                <contains casesensitive="true" string="${run.jvmargs.ide}" substring="-agentpath:"/>
		                <contains casesensitive="true" string="${run.jvmargs.ide}" substring="-javaagent:"/>
		            </or>
		        </condition>
		    </target>
		    
		    <target if="jnlp-file-exists+netbeans.home" name="-profile-check-jnlp">
		        <antcall target="-profile-check-1"/>
		    </target>
		    
		    <target name="-do-jfxws-profile" depends="-mark-project-state-profiling,-mark-project-needs-jnlp,
		            -check-jdk-7u4or5-mac,jar,-check-jfx-webstart,-resolve-jnlp-file,-check-jfx-runtime,-warn-insufficient-signing">
		        <echo message="Executing ${jfx.deployment.jnlp} in profile mode using ${active.webstart.executable}"/>
		        <property name="run.jvmargs.ide" value=""/>        
		        <exec executable="${active.webstart.executable}">
		            <env key="JAVAWS_VM_ARGS" value="${run.jvmargs.ide}"/>
		            <arg value="-wait"/>
		            <arg file="${jfx.deployment.jnlp}"/>
		        </exec>
		    </target>
		    
		    <target name="jfxws-profile" if="profiler.configured" 
		        depends="-profile-check-1"
		        description="Profile JavaFX javaws project in IDE">
		        <startprofiler/>
		        <antcall target="-do-jfxws-profile"/>
		    </target>
		    
		    <target name="jfxws-run-noscript" depends="-set-fallback-no-javascript, jfxws-run"/>
		
		    <target name="jfxws-debug-noscript" depends="-set-fallback-no-javascript, jfxws-debug"/>
		
		    <target name="jfxws-profile-noscript" depends="-set-fallback-no-javascript, jfxws-profile"/>
		
		
		    <!-- Running/Debugging/Profiling in Browser -->
		
		    <target name="-check-selected-browser-path" depends="-check-default-run-config">
		        <condition property="javafx.run.inbrowser.undefined">
		            <or>
		                <and>
		                    <isset property="javafx.run.inbrowser"/>
		                    <equals arg1="${javafx.run.inbrowser}" arg2="undefined"/>
		                </and>
		                <and>
		                    <isset property="javafx.run.inbrowser.path"/>
		                    <equals arg1="${javafx.run.inbrowser.path}" arg2="undefined"/>
		                </and>
		            </or>
		        </condition>
		        <condition property="javafx.run.inbrowser.path-exists">
		            <and>
		                <isset property="javafx.run.inbrowser.path"/>
		                <available file="${javafx.run.inbrowser.path}"/>
		            </and>
		        </condition>
		        <fail message="Error:${line.separator}Browser selection not recognizable from ${config} run configuration.${line.separator}Please go to Project Properties dialog, category Run, to select a valid browser." unless="javafx.run.inbrowser.path"/>
		        <fail message="Error:${line.separator}No browser defined in ${config} run configuration.${line.separator}Please verify in Tools->Options dialog that NetBeans recognizes a valid browser, then go to Project Properties dialog, category Run, to select a valid browser." if="javafx.run.inbrowser.undefined"/>
		        <fail message="Error:${line.separator}Browser ${javafx.run.inbrowser.path} referred from ${config} run configuration can not be found.${line.separator}(This can happen, e.g, when the JavaFX Project is transferred to another system.)${line.separator}Please go to Project Properties dialog, category Run, to select a valid browser." unless="javafx.run.inbrowser.path-exists"/>
		    </target>
		
		    <target name="-substitute-template-processed-html-file" depends="-check-project" if="html-template-available">
		        <deploy-process-template/>
		    </target>
		    <target name="-check-template-processed-html-file" depends="-substitute-template-processed-html-file">
		        <condition property="html-file-exists">
		            <and>
		                <isset property="html-template-available"/>
		                <available file="${javafx.run.htmltemplate.processed}"/>
		            </and>
		        </condition>
		    </target>
		    
		    <target name="-set-template-processed-html-file" depends="-check-template-processed-html-file" if="html-file-exists">
		        <property name="jfx.deployment.html" location="${javafx.run.htmltemplate.processed}"/>
		    </target>
		    
		    <target name="-set-html-file" depends="-set-template-processed-html-file" unless="html-file-exists">
		        <basename property="jfx.deployment.base" file="${jfx.deployment.jar}" suffix=".jar"/>
		        <property name="jfx.deployment.html" location="${jfx.deployment.dir}${file.separator}${jfx.deployment.base}.html"/>
		        <condition property="html-file-exists">
		            <available file="${jfx.deployment.html}"/>
		        </condition>
		        <condition property="html-file-exists+netbeans.home">
		            <and>
		                <isset property="html-file-exists"/>
		                <isset property="netbeans.home"/>
		            </and>
		        </condition>
		    </target>
		
		    <!-- set property javafx.enable.concurrent.external.runs=true to enable multiple runs of the same WebStart or Run-in-Browser project -->
		    <target name="-check-concurrent-html-runs" depends="-set-html-file">
		        <condition property="disable-concurrent-runs">
		            <or>
		                <not>
		                    <and>
		                        <isset property="javafx.enable.concurrent.external.runs"/>
		                        <equals arg1="${javafx.enable.concurrent.external.runs}" arg2="true" trim="true"/>
		                    </and>
		                </not>
		                <and>
		                    <isset property="html-template-available"/>
		                    <available file="${javafx.run.htmltemplate.processed}"/>
		                </and>
		            </or>
		        </condition>
		        <condition property="temp.run.html" value="${jfx.deployment.html}">
		            <isset property="disable-concurrent-runs"/>
		        </condition>
		    </target>
		    <target name="-warn-concurrent-html-runs" unless="disable-concurrent-runs">
		        <echo message="Note: Concurrent Run in Browser enabled.${line.separator}Temporary directory ${temp.run.dir}${line.separator}will remain unused when execution in browser has finished. Use project Clean to delete unused directories."/>
		    </target>
		
		    <target name="jfxbe-run" if="html-file-exists" depends="-mark-project-state-running,-clean-if-config-changed,-mark-project-needs-jnlp,-check-jdk-7u4or5-mac,jar,
		            -check-selected-browser-path,-set-html-file,-check-jfx-runtime,-check-concurrent-html-runs,-create-temp-run-dir,-warn-insufficient-signing"
		            description="Start JavaFX execution in browser">
		        <echo message="Executing ${temp.run.html} using ${javafx.run.inbrowser}"/>
		        <echo message="(${javafx.run.inbrowser.path})"/>
		        <property name="javafx.run.inbrowser.arguments" value=""/>
		        <exec executable="${javafx.run.inbrowser.path}">
		            <arg line="${javafx.run.inbrowser.arguments}"/>
		            <arg file="${temp.run.html}"/>
		        </exec>
		        <antcall target="-warn-concurrent-html-runs"/>
		    </target>
		    
		    <target name="jfxbe-debug" if="html-file-exists+netbeans.home" depends="-mark-project-state-debugging-in-browser,-init-debug-args,
		            clean,-debug-start-debugger,-mark-project-needs-jnlp,-check-jdk-7u4or5-mac,jar,
		            -check-selected-browser-path,-set-html-file,-check-jfx-runtime,-warn-insufficient-signing,
		            -debug-jfxbe-debuggee" description="Debug JavaFX project in browser">
		        <!-- after the session clean up the jnlp containing debug settings -->
		        <antcall target="clean"/>
		    </target>
		        
		    <target name="-debug-jfxbe-debuggee" depends="-init-debug-args">
		        <echo message="Executing ${jfx.deployment.html} in debug mode using ${javafx.run.inbrowser}"/>
		        <echo message="(${javafx.run.inbrowser.path})"/>
		        <property name="javafx.run.inbrowser.arguments" value=""/>
		        <exec executable="${javafx.run.inbrowser.path}">
		            <arg line="${javafx.run.inbrowser.arguments}"/>
		            <env key="_JPI_VM_OPTIONS" value="-agentlib:jdwp=transport=${debug-transport},address=${jpda.address}"/>
		            <arg file="${jfx.deployment.html}"/>
		        </exec>
		    </target>
		
		    <target if="html-file-exists+netbeans.home" name="-profile-check-html">
		        <antcall target="-profile-check-1"/>
		    </target>
		
		    <target name="-do-jfxbe-profile" depends="-mark-project-state-profiling,-mark-project-needs-jnlp,
		            -check-jdk-7u4or5-mac,jar,-check-selected-browser-path,-set-html-file,-check-jfx-runtime,-warn-insufficient-signing">
		        <echo message="Executing ${jfx.deployment.html} in profile mode using ${javafx.run.inbrowser}"/>
		        <echo message="(${javafx.run.inbrowser.path})"/>
		        <property name="run.jvmargs.ide" value=""/>
		        <property name="javafx.run.inbrowser.arguments" value=""/>
		        <exec executable="${javafx.run.inbrowser.path}">
		            <arg line="${javafx.run.inbrowser.arguments}"/>
		            <env key="_JPI_VM_OPTIONS" value="${run.jvmargs.ide}"/>
		            <arg file="${jfx.deployment.html}"/>
		        </exec>
		    </target>
		
		    <target name="jfxbe-profile" if="profiler.configured"
		        depends="-profile-check-html"
		        description="Profile JavaFX project in browser">
		        <startprofiler/>
		        <antcall target="-do-jfxbe-profile"/>
		    </target>
		
		    <target name="jfxbe-run-noscript" depends="-set-fallback-no-javascript, jfxbe-run"/>
		
		    <target name="jfxbe-debug-noscript" depends="-set-fallback-no-javascript, jfxbe-debug"/>
		
		    <target name="jfxbe-profile-noscript" depends="-set-fallback-no-javascript, jfxbe-profile"/>
		
		
		</project>
		'''
	}
	
	def jfx() {
		'''
		<?xml version="1.0" encoding="UTF-8"?>
		<!--
		*** GENERATED FROM TEMPLATE - DO NOT EDIT ***
		***       EDIT ../build.xml INSTEAD       ***
		-->
		
		<project name="jfx-impl" default="jfx-deployment" basedir=".." xmlns:j2seproject1="http://www.netbeans.org/ns/j2se-project/1" 
		         xmlns:j2seproject3="http://www.netbeans.org/ns/j2se-project/3" xmlns:fx="javafx:com.sun.javafx.tools.ant">
		    <description>JavaFX-specific Ant calls</description>
		
		
		    <!-- Empty placeholders for easier customization in ../build.xml -->
		    
		    <target name="-pre-jfx-jar">
		        <!-- Called right before <fx:jar> task. You can override this target in the ../build.xml file. -->
		    </target>
		
		    <target name="-post-jfx-jar">
		        <!-- Called right after <fx:jar> task. You can override this target in the ../build.xml file. -->
		    </target>
		
		    <target name="-pre-jfx-deploy">
		        <!-- Called right before <fx:deploy> task. You can override this target in the ../build.xml file. -->
		    </target>
		
		    <target name="-post-jfx-deploy">
		        <!-- Called right after <fx:deploy> task. You can override this target in the ../build.xml file. -->
		    </target>
		    
		    <target name="-pre-jfx-native">
		        <!-- Called right before the call to native packager (just after -pre-jfx-deploy). You can override this target in the ../build.xml file. -->
		    </target>
		
		    <target name="-post-jfx-native">
		        <!-- Called right after the call to native packager (just after -post-jfx-deploy). You can override this target in the ../build.xml file. -->
		    </target>
		    
		    
		    <!-- Check system and JDK version -->
		
		    <target name="-check-operating-system">
		        <condition property="running.on.mac">
		            <os family="mac"/>
		        </condition>
		        <condition property="running.on.unix">
		            <os family="unix"/>
		        </condition>
		        <condition property="running.on.windows">
		            <os family="windows"/>
		        </condition>
		        <echo message="running.on.mac = ${running.on.mac}" level="verbose"/>
		        <echo message="running.on.unix = ${running.on.unix}" level="verbose"/>
		        <echo message="running.on.windows = ${running.on.windows}" level="verbose"/>
		    </target>
		
		    <target name="-check-platform-home-fxsdk-java" depends="-check-property-javafx.sdk" if="javafx.sdk.defined">
		        <condition property="do.set.platform.home.fxsdk.java">
		            <and>
		                <not><isset property="active.platform.home.java.executable"/></not>
		                <or>
		                    <available file="${javafx.sdk}${file.separator}bin${file.separator}java"/>
		                    <available file="${javafx.sdk}${file.separator}bin${file.separator}java.exe"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-platform-home-fxsdk-java" depends="-check-platform-home-fxsdk-java" if="do.set.platform.home.fxsdk.java">
		        <property name="active.platform.home.java.executable" value="${javafx.sdk}${file.separator}bin${file.separator}java"/>
		    </target>
		    <target name="-check-platform-home-java" if="platform.home">
		        <condition property="do.set.platform.home.java">
		            <and>
		                <not><isset property="active.platform.home.java.executable"/></not>
		                <or>
		                    <available file="${platform.home}${file.separator}bin${file.separator}java"/>
		                    <available file="${platform.home}${file.separator}bin${file.separator}java.exe"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-platform-home-java" depends="-set-platform-home-fxsdk-java,-check-platform-home-java" if="do.set.platform.home.java">
		        <property name="active.platform.home.java.executable" value="${platform.home}${file.separator}bin${file.separator}java"/>
		    </target>
		    <target name="-check-platform-home-probjdk-java" unless="active.platform.home.java.executable">
		        <condition property="do.set.platform.home.probjdk.java">
		            <and>
		                <not><isset property="active.platform.home.java.executable"/></not>
		                <or>
		                    <available file="${java.home}${file.separator}..${file.separator}bin${file.separator}java"/>
		                    <available file="${java.home}${file.separator}..${file.separator}bin${file.separator}java.exe"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-platform-home-probjdk-java" depends="-set-platform-home-java,-check-platform-home-probjdk-java" if="do.set.platform.home.probjdk.java">
		        <property name="active.platform.home.java.executable" value="${java.home}${file.separator}..${file.separator}bin${file.separator}java"/>
		    </target>
		    <target name="-check-platform-home-envjdk-java" unless="active.platform.home.java.executable">
		        <property environment="env"/>
		        <condition property="do.set.platform.home.envjdk.java">
		            <and>
		                <not><isset property="active.platform.home.java.executable"/></not>
		                <or>
		                    <available file="${env.JAVA_HOME}${file.separator}bin${file.separator}java"/>
		                    <available file="${env.JAVA_HOME}${file.separator}bin${file.separator}java.exe"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-platform-home-envjdk-java" depends="-set-platform-home-probjdk-java,-check-platform-home-envjdk-java" if="do.set.platform.home.envjdk.java">
		        <property environment="env"/>
		        <property name="active.platform.home.java.executable" value="${env.JAVA_HOME}${file.separator}bin${file.separator}java"/>
		    </target>
		    <target name="-check-platform-home-fxrt-java" depends="-check-property-javafx.runtime" if="javafx.runtime.defined">
		        <condition property="do.set.platform.home.fxrt.java">
		            <and>
		                <not><isset property="active.platform.home.java.executable"/></not>
		                <or>
		                    <available file="${javafx.runtime}${file.separator}bin${file.separator}java"/>
		                    <available file="${javafx.runtime}${file.separator}bin${file.separator}java.exe"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-platform-home-fxrt-java" depends="-set-platform-home-envjdk-java,-check-platform-home-fxrt-java" if="do.set.platform.home.fxrt.java">
		        <property name="active.platform.home.java.executable" value="${javafx.runtime}${file.separator}bin${file.separator}java"/>
		        <echo message="Warning: java executable not found in JDK, evaluating java executable in RT instead." level="info"/>
		    </target>
		    <target name="-check-platform-home-jre-java" unless="active.platform.home.java.executable">
		        <condition property="do.set.platform.home.jre.java">
		            <and>
		                <not><isset property="active.platform.home.java.executable"/></not>
		                <or>
		                    <available file="${java.home}${file.separator}bin${file.separator}java"/>
		                    <available file="${java.home}${file.separator}bin${file.separator}java.exe"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-platform-home-jre-java" depends="-set-platform-home-fxrt-java,-check-platform-home-jre-java" if="do.set.platform.home.jre.java">
		        <property name="active.platform.home.java.executable" value="${java.home}${file.separator}bin${file.separator}java"/>
		        <echo message="Warning: java executable not found in JDK, evaluating java executable in RT instead." level="info"/>
		    </target>
		    <target name="-check-platform-home" depends="-set-platform-home-jre-java">
		        <echo message="active.platform.home.java.executable = ${active.platform.home.java.executable}" level="verbose"/>
		        <fail message="Error:${line.separator}java executable not found !" unless="active.platform.home.java.executable"/>
		    </target>
		        
		    <target name="-check-jdk-version" depends="-do-init,-check-platform-home" unless="jdk-version-checked-in-jfximpl">
		        <local name="version-output"/>
		        <exec executable="${active.platform.home.java.executable}" outputproperty="version-output">
		            <arg value="-version"/>
		        </exec>
		        <echo message="version-output:${line.separator}${version-output}" level="verbose"/>
		        <condition property="have-jdk-older-than-1.6">
		            <or>
		                <contains string="${version-output}" substring="java version &quot;1.0"/>
		                <contains string="${version-output}" substring="java version &quot;1.1"/>
		                <contains string="${version-output}" substring="java version &quot;1.2"/>
		                <contains string="${version-output}" substring="java version &quot;1.3"/>
		                <contains string="${version-output}" substring="java version &quot;1.4"/>
		                <contains string="${version-output}" substring="java version &quot;1.5"/>
		            </or>
		        </condition>
		        <fail message="Error:${line.separator}JavaFX 2.0+ projects require JDK version 1.6+ !" if="have-jdk-older-than-1.6"/>
		        <condition property="have-jdk-7u4or5-mac">
		            <and>
		                <or>
		                    <contains string="${version-output}" substring="java version &quot;1.7.0_04"/>
		                    <contains string="${version-output}" substring="java version &quot;1.7.0_05"/>
		                </or>
		                <os family="mac"/>
		            </and>
		        </condition>
		        <condition property="have-jdk-pre7u6">
		            <or>
		                <isset property="have-jdk-older-than-1.6"/>
		                <contains string="${version-output}" substring="java version &quot;1.6"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0&quot;"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_01"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_02"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_03"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_04"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_05"/>
		            </or>
		        </condition>
		        <condition property="have-jdk-pre7u14">
		            <or>
		                <isset property="have-jdk-pre7u6"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_06"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_07"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_08"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_09"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_10"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_11"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_12"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_13"/>
		            </or>
		        </condition>
		        <property name="jdk-version-checked-in-jfximpl" value="true"/>
		        <echo message="have-jdk-7u4or5-mac = ${have-jdk-7u4or5-mac}" level="verbose"/>
		        <echo message="have-jdk-pre7u6 = ${have-jdk-pre7u6}" level="verbose"/>
		        <echo message="have-jdk-pre7u14 = ${have-jdk-pre7u14}" level="verbose"/>
		    </target>
		        
		    <target name="-check-ant-jre-version" unless="ant-jre-version-checked-in-jfximpl">
		        <local name="version-output"/>
		        <exec executable="${java.home}${file.separator}bin${file.separator}java" outputproperty="version-output">
		            <arg value="-version"/>
		        </exec>
		        <echo message="version-output:${line.separator}${version-output}" level="verbose"/>
		        <condition property="have-ant-jre-pre7u6">
		            <or>
		                <contains string="${version-output}" substring="java version &quot;1.0"/>
		                <contains string="${version-output}" substring="java version &quot;1.1"/>
		                <contains string="${version-output}" substring="java version &quot;1.2"/>
		                <contains string="${version-output}" substring="java version &quot;1.3"/>
		                <contains string="${version-output}" substring="java version &quot;1.4"/>
		                <contains string="${version-output}" substring="java version &quot;1.5"/>
		                <contains string="${version-output}" substring="java version &quot;1.6"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0&quot;"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_01"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_02"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_03"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_04"/>
		                <contains string="${version-output}" substring="java version &quot;1.7.0_05"/>
		            </or>
		        </condition>
		        <condition property="have-jdk7-css2bin-bug">
		            <!-- as of NB7.4 release date the external css-to-bss converter is unreliable in all JDK7 versions before 7u40 (with exception of 7u14)-->
		            <and>
		                <contains string="${version-output}" substring="java version &quot;1.7"/>
		                <not><matches string="${version-output}" pattern="\bjava version &quot;1\.7\.0_(14|[4-9].)"/></not>
		            </and>
		        </condition>
		        <property name="ant-jre-version-checked-in-jfximpl" value="true"/>
		        <echo message="have-ant-jre-pre7u6 = ${have-ant-jre-pre7u6}" level="verbose"/>
		        <echo message="have-jdk7-css2bin-bug = ${have-jdk7-css2bin-bug}" level="verbose"/>
		    </target>
		
		    <target name="-check-jdk-7u4or5-mac" depends="-check-jdk-version" if="have-jdk-7u4or5-mac">
		        <fail message="Error:${line.separator}JDK 7u4 Mac and 7u5 Mac do not support WebStart and JavaFX 2.0+ browser plugin technologies.${line.separator}Please upgrade to JDK 7u6 or later."/>
		    </target>
		
		    
		    <!-- Check availability of JavaFX SDK deployment support (ant-javafx.jar) -->
		
		    <target name="-check-endorsed-javafx-ant-classpath">
		        <condition property="endorsed-javafx-ant-classpath-available">
		            <and>
		                <isset property="endorsed.javafx.ant.classpath"/>
		                <not>
		                    <equals arg1="${endorsed.javafx.ant.classpath}" arg2=""/>
		                </not>
		            </and>
		        </condition>
		        <echo message="endorsed-javafx-ant-classpath-available = ${endorsed-javafx-ant-classpath-available}" level="verbose"/>
		    </target>
		
		    <target name="-check-property-javafx.sdk">
		        <echo message="javafx.sdk = ${javafx.sdk}" level="verbose"/>
		        <condition property="javafx.sdk.defined">
		            <and>
		                <isset property="javafx.sdk"/>
		                <not><contains string="${javafx.sdk}" substring="$${platform" casesensitive="false"/></not>
		            </and>
		        </condition>
		        <condition property="javafx.sdk.missing+default">
		            <and>
		                <equals arg1="${platform.active}" arg2="Default_JavaFX_Platform" trim="true"/>
		                <not><isset property="javafx.sdk.defined"/></not>
		            </and>
		        </condition>
		        <condition property="javafx.sdk.missing-default">
		            <and>
		                <not><equals arg1="${platform.active}" arg2="Default_JavaFX_Platform" trim="true"/></not>
		                <not><isset property="javafx.sdk.defined"/></not>
		            </and>
		        </condition>
		        <echo message="javafx.sdk.defined = ${javafx.sdk.defined}" level="verbose"/>
		        <echo message="javafx.sdk.missing+default = ${javafx.sdk.missing+default}" level="verbose"/>
		        <echo message="javafx.sdk.missing-default = ${javafx.sdk.missing-default}" level="verbose"/>
		    </target>
		
		    <target name="-check-ant-javafx-in-fxsdk-lib" depends="-check-property-javafx.sdk" if="javafx.sdk.defined">
		        <condition property="do.set.ant-javafx.in.fxsdk.lib">
		            <and>
		                <not><isset property="ant-javafx.jar.location"/></not>
		                <available file="${javafx.sdk}${file.separator}lib${file.separator}ant-javafx.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-ant-javafx-in-fxsdk-lib" depends="-check-ant-javafx-in-fxsdk-lib" if="do.set.ant-javafx.in.fxsdk.lib">
		        <property name="ant-javafx.jar.location" value="${javafx.sdk}${file.separator}lib${file.separator}ant-javafx.jar"/>
		    </target>
		    <target name="-check-ant-javafx-in-fxsdk-tools" depends="-check-property-javafx.sdk" if="javafx.sdk.defined">
		        <condition property="do.set.ant-javafx.in.fxsdk.tools">
		            <and>
		                <not><isset property="ant-javafx.jar.location"/></not>
		                <available file="${javafx.sdk}${file.separator}tools${file.separator}ant-javafx.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-ant-javafx-in-fxsdk-tools" depends="-set-ant-javafx-in-fxsdk-lib,-check-ant-javafx-in-fxsdk-tools" if="do.set.ant-javafx.in.fxsdk.tools">
		        <property name="ant-javafx.jar.location" value="${javafx.sdk}${file.separator}tools${file.separator}ant-javafx.jar"/>
		    </target>
		    <target name="-check-ant-javafx-in-platform-home-lib" if="platform.home">
		        <condition property="do.set.ant-javafx.in.platform.home.lib">
		            <and>
		                <not><isset property="ant-javafx.jar.location"/></not>
		                <available file="${platform.home}${file.separator}lib${file.separator}ant-javafx.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-ant-javafx-in-platform-home-lib" depends="-set-ant-javafx-in-fxsdk-tools,-check-ant-javafx-in-platform-home-lib" if="do.set.ant-javafx.in.platform.home.lib">
		        <property name="ant-javafx.jar.location" value="${platform.home}${file.separator}lib${file.separator}ant-javafx.jar"/>
		    </target>
		    <target name="-check-ant-javafx-in-platform-home-tools" if="platform.home">
		        <condition property="do.set.ant-javafx.in.platform.home.tools">
		            <and>
		                <not><isset property="ant-javafx.jar.location"/></not>
		                <available file="${platform.home}${file.separator}tools${file.separator}ant-javafx.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-ant-javafx-in-platform-home-tools" depends="-set-ant-javafx-in-platform-home-lib,-check-ant-javafx-in-platform-home-tools" if="do.set.ant-javafx.in.platform.home.tools">
		        <property name="ant-javafx.jar.location" value="${platform.home}${file.separator}tools${file.separator}ant-javafx.jar"/>
		    </target>
		    <target name="-check-ant-javafx-in-probjdk-lib" unless="ant-javafx.jar.location">
		        <condition property="do.set.ant-javafx.in.probjdk.lib.has_jre">
		            <available file="${java.home}${file.separator}..${file.separator}lib${file.separator}ant-javafx.jar"/>
		        </condition>
		        <condition property="do.set.ant-javafx.in.probjdk.lib.no_jre">
		            <available file="${java.home}${file.separator}lib${file.separator}ant-javafx.jar"/>
		        </condition>
		        <condition property="do.set.ant-javafx.in.probjdk.lib">
		            <and>
		                <not><isset property="ant-javafx.jar.location"/></not>
		                <or>
		                    <isset property="do.set.ant-javafx.in.probjdk.lib.has_jre"/>
		                    <isset property="do.set.ant-javafx.in.probjdk.lib.no_jre"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-ant-javafx-in-probjdk-lib" depends="-set-ant-javafx-in-platform-home-tools,-check-ant-javafx-in-probjdk-lib" if="do.set.ant-javafx.in.probjdk.lib">
		        <condition property="ant-javafx.jar.location" value="${java.home}${file.separator}..${file.separator}lib${file.separator}ant-javafx.jar" else="${java.home}${file.separator}lib${file.separator}ant-javafx.jar">
		            <isset property="do.set.ant-javafx.in.probjdk.lib.has_jre"/>
		        </condition>
		    </target>
		    <target name="-check-ant-javafx-in-probjdk-tools" unless="ant-javafx.jar.location">
		        <condition property="do.set.ant-javafx.in.probjdk.tools.has_jre">
		            <available file="${java.home}${file.separator}..${file.separator}tools${file.separator}ant-javafx.jar"/>
		        </condition>
		        <condition property="do.set.ant-javafx.in.probjdk.tools.no_jre">
		            <available file="${java.home}${file.separator}tools${file.separator}ant-javafx.jar"/>
		        </condition>
		        <condition property="do.set.ant-javafx.in.probjdk.tools">
		            <and>
		                <not><isset property="ant-javafx.jar.location"/></not>
		                <or>
		                    <isset property="do.set.ant-javafx.in.probjdk.tools.has_jre"/>
		                    <isset property="do.set.ant-javafx.in.probjdk.tools.no_jre"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-ant-javafx-in-probjdk-tools" depends="-set-ant-javafx-in-probjdk-lib,-check-ant-javafx-in-probjdk-tools" if="do.set.ant-javafx.in.probjdk.tools">
		        <condition property="ant-javafx.jar.location" value="${java.home}${file.separator}..${file.separator}tools${file.separator}ant-javafx.jar" else="${java.home}${file.separator}tools${file.separator}ant-javafx.jar">
		            <isset property="do.set.ant-javafx.in.probjdk.tools.has_jre"/>
		        </condition>
		    </target>
		    <target name="-check-ant-javafx-in-macjdk-lib" unless="ant-javafx.jar.location">
		        <condition property="do.set.ant-javafx.in.macjdk.lib">
		            <and>
		                <not><isset property="ant-javafx.jar.location"/></not>
		                <available file="${java.home}${file.separator}lib${file.separator}ant-javafx.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-ant-javafx-in-macjdk-lib" depends="-set-ant-javafx-in-probjdk-tools,-check-ant-javafx-in-macjdk-lib" if="do.set.ant-javafx.in.macjdk.lib">
		        <property name="ant-javafx.jar.location" value="${java.home}${file.separator}lib${file.separator}ant-javafx.jar"/>
		    </target>
		    <target name="-check-ant-javafx-in-envjdk-lib" unless="ant-javafx.jar.location">
		        <property environment="env"/>
		        <condition property="do.set.ant-javafx.in.envjdk.lib">
		            <and>
		                <not><isset property="ant-javafx.jar.location"/></not>
		                <available file="${env.JAVA_HOME}${file.separator}lib${file.separator}ant-javafx.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-ant-javafx-in-envjdk-lib" depends="-set-ant-javafx-in-macjdk-lib,-check-ant-javafx-in-envjdk-lib" if="do.set.ant-javafx.in.envjdk.lib">
		        <property name="ant-javafx.jar.location" value="${env.JAVA_HOME}${file.separator}lib${file.separator}ant-javafx.jar"/>
		    </target>
		    <target name="-check-ant-javafx-in-envjdk-tools" unless="ant-javafx.jar.location">
		        <property environment="env"/>
		        <condition property="do.set.ant-javafx.in.envjdk.tools">
		            <and>
		                <not><isset property="ant-javafx.jar.location"/></not>
		                <available file="${env.JAVA_HOME}${file.separator}tools${file.separator}ant-javafx.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-ant-javafx-in-envjdk-tools" depends="-set-ant-javafx-in-envjdk-lib,-check-ant-javafx-in-envjdk-tools" if="do.set.ant-javafx.in.envjdk.tools">
		        <property name="ant-javafx.jar.location" value="${env.JAVA_HOME}${file.separator}tools${file.separator}ant-javafx.jar"/>
		    </target>
		    <target name="-pre-check-ant-javafx-version" depends="-set-ant-javafx-in-envjdk-tools" unless="ant-javafx-version-already-checked-in-jfximpl">
		        <condition property="do.check.ant-javafx.version">
		            <and>
		                <isset property="ant-javafx.jar.location"/>
		                <not><isset property="ant-javafx-version-already-checked-in-jfximpl"/></not>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-endorsed-javafx-ant-classpath" depends="-check-endorsed-javafx-ant-classpath,-pre-check-ant-javafx-version" if="endorsed-javafx-ant-classpath-available">
		        <property name="javafx.ant.classpath" value="${endorsed.javafx.ant.classpath}:${ant-javafx.jar.location}"/>
		    </target>
		    <target name="-set-javafx-ant-classpath" depends="-check-endorsed-javafx-ant-classpath,-pre-check-ant-javafx-version" unless="endorsed-javafx-ant-classpath-available">
		        <property name="javafx.ant.classpath" value="${ant-javafx.jar.location}"/>
		    </target>
		    <target name="-check-ant-javafx-version" depends="-pre-check-ant-javafx-version,
		            -set-endorsed-javafx-ant-classpath,-set-javafx-ant-classpath" if="do.check.ant-javafx.version">
		        <echo message="ant-javafx.jar.location = ${ant-javafx.jar.location}" level="verbose"/>
		        <echo message="javafx.ant.classpath = ${javafx.ant.classpath}" level="verbose"/>
		        <taskdef resource="com/sun/javafx/tools/ant/antlib.xml"
		            uri="javafx:com.sun.javafx.tools.ant"
		            classpath="${javafx.ant.classpath}"/>
		        <condition property="have-fx-ant-init">
		            <typefound name="javafx:com.sun.javafx.tools.ant:init-ant"/>
		        </condition>
		        <property name="ant-javafx-version-already-checked-in-jfximpl" value="true"/>
		        <echo message="have-fx-ant-init = ${have-fx-ant-init}" level="verbose"/>
		    </target>
		    <target name="-check-jfx-sdk-version-old" depends="-check-ant-javafx-version" unless="have-fx-ant-init">
		        <property name="javafx.ant.version" value="1.0"/>
		    </target>
		    <target name="-check-jfx-sdk-version-new" depends="-check-ant-javafx-version" if="have-fx-ant-init">
		        <fx:init-ant/>
		        <condition property="have-fx-ant-api-1.1">
		            <!-- new features from JavaFX 2.0.2 are available in API version 1.1 or later -->
		            <matches pattern="1.[1-9]" string="${javafx.ant.version}"/>
		        </condition>
		        <condition property="have-fx-ant-api-1.2">
		            <!-- new features from JavaFX 2.2 are available in API version 1.2 or later -->
		            <matches pattern="1.[2-9]" string="${javafx.ant.version}"/>
		        </condition>
		    </target>
		    <target name="-check-jfx-sdk-version" depends="-check-jfx-sdk-version-old, -check-jfx-sdk-version-new" unless="jfx.sdk.version.checked">
		        <echo message="Detected JavaFX Ant API version ${javafx.ant.version}" level="info"/>
		        <echo message="have-fx-ant-api-1.1 = ${have-fx-ant-api-1.1}" level="verbose"/>
		        <echo message="have-fx-ant-api-1.2 = ${have-fx-ant-api-1.2}" level="verbose"/>
		        <echo message="javafx.ant.classpath = ${javafx.ant.classpath}" level="verbose"/>
		        <property name="jfx.sdk.version.checked" value="true"/>
		    </target>
		
		    <target name="-check-jfx-deployment" depends="-check-jdk-version,-check-jfx-sdk-version">
		        <condition property="jfx-deployment-available">
		            <and>
		                <or>
		                    <isset property="do.set.ant-javafx.in.fxsdk.lib"/>
		                    <isset property="do.set.ant-javafx.in.fxsdk.tools"/>
		                    <isset property="do.set.ant-javafx.in.platform.home.lib"/>
		                    <isset property="do.set.ant-javafx.in.platform.home.tools"/>
		                    <isset property="do.set.ant-javafx.in.probjdk.lib"/>
		                    <isset property="do.set.ant-javafx.in.probjdk.tools"/>
		                    <isset property="do.set.ant-javafx.in.envjdk.lib"/>
		                    <isset property="do.set.ant-javafx.in.envjdk.tools"/>
		                </or>
		                <isset property="ant-javafx.jar.location"/>
		            </and>
		        </condition>
		        <condition property="jfx-deployment-missing+jdk7u6">
		            <and>
		                <not><isset property="jfx-deployment-available"/></not>
		                <not><isset property="have-jdk-pre7u6"/></not>
		            </and>
		        </condition>
		        <condition property="jfx-deployment-missing+javafx.sdk.missing+default">
		            <and>
		                <not><isset property="jfx-deployment-available"/></not>
		                <isset property="have-jdk-pre7u6"/>
		                <isset property="javafx.sdk.missing+default"/>
		            </and>
		        </condition>
		        <condition property="jfx-deployment-missing+javafx.sdk.missing-default">
		            <and>
		                <not><isset property="jfx-deployment-available"/></not>
		                <isset property="have-jdk-pre7u6"/>
		                <isset property="javafx.sdk.missing-default"/>
		            </and>
		        </condition>
		        <fail message="Error:${line.separator}JavaFX deployment library not found in active JDK.${line.separator}Please check that the JDK is correctly installed and its version is at least 7u4 on Mac or 7u6 on other systems." if="jfx-deployment-missing+jdk7u6"/>
		        <fail message="Error:${line.separator}JavaFX deployment library not found.${line.separator}JavaFX SDK path undefined. Check the definition of ${platform.active} in Java Platform Manager${line.separator}(or directly the properties platform.active and javafx.sdk in project.properties file).${line.separator}Note: If missing, the default JavaFX-enabled platform gets created automatically when creating a new JavaFX Project." if="jfx-deployment-missing+javafx.sdk.missing+default"/>
		        <fail message="Error:${line.separator}JavaFX deployment library not found.${line.separator}JavaFX SDK path undefined. Check the definition of ${platform.active} in Java Platform Manager${line.separator}(or directly the properties platform.active and javafx.sdk in project.properties file)." if="jfx-deployment-missing+javafx.sdk.missing-default"/>
		        <fail message="Error:${line.separator}JavaFX deployment library not found." unless="jfx-deployment-available"/>
		        <echo message="jfx-deployment-available = ${jfx-deployment-available}" level="verbose"/>
		    </target>
		    
		    
		    <!-- Check availability of main JavaFX runtime jar (jfxrt.jar) -->
		
		    <target name="-check-property-javafx.runtime">
		        <echo message="javafx.runtime = ${javafx.runtime}" level="verbose"/>
		        <condition property="javafx.runtime.defined">
		            <and>
		                <isset property="javafx.runtime"/>
		                <not><contains string="${javafx.runtime}" substring="$${platform" casesensitive="false"/></not>
		            </and>
		        </condition>
		        <condition property="javafx.runtime.missing+default">
		            <and>
		                <equals arg1="${platform.active}" arg2="Default_JavaFX_Platform" trim="true"/>
		                <not><isset property="javafx.runtime.defined"/></not>
		            </and>
		        </condition>
		        <condition property="javafx.runtime.missing-default">
		            <and>
		                <not><equals arg1="${platform.active}" arg2="Default_JavaFX_Platform" trim="true"/></not>
		                <not><isset property="javafx.runtime.defined"/></not>
		            </and>
		        </condition>
		        <echo message="javafx.runtime.defined = ${javafx.runtime.defined}" level="verbose"/>
		        <echo message="javafx.runtime.missing+default = ${javafx.runtime.missing+default}" level="verbose"/>
		        <echo message="javafx.runtime.missing-default = ${javafx.runtime.missing-default}" level="verbose"/>
		    </target>
		
		    <target name="-check-jfxrt-in-fxrt" depends="-check-property-javafx.runtime" if="javafx.runtime.defined">
		        <condition property="do.set.jfxrt.in.fxrt.old">
		            <and>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${javafx.runtime}${file.separator}lib${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		        <condition property="do.set.jfxrt.in.fxrt.new">
		            <and>
		                <not><isset property="do.set.jfxrt.in.fxrt.old"/></not>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${javafx.runtime}${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-jfxrt-in-fxrt-old" depends="-check-jfxrt-in-fxrt" if="do.set.jfxrt.in.fxrt.old">
		        <property name="jfxrt.jar.location" value="${javafx.runtime}${file.separator}lib${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-set-jfxrt-in-fxrt-new" depends="-set-jfxrt-in-fxrt-old,-check-jfxrt-in-fxrt" if="do.set.jfxrt.in.fxrt.new">
		        <property name="jfxrt.jar.location" value="${javafx.runtime}${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-check-jfxrt-in-fxsdk-jre" depends="-check-property-javafx.sdk" if="javafx.sdk.defined">
		        <condition property="do.set.jfxrt.in.fxsdk.jre.old">
		            <and>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${javafx.sdk}${file.separator}jre${file.separator}lib${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		        <condition property="do.set.jfxrt.in.fxsdk.jre.new">
		            <and>
		                <not><isset property="do.set.jfxrt.in.fxsdk.jre.old"/></not>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${javafx.sdk}${file.separator}jre${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-jfxrt-in-fxsdk-jre-old" depends="-set-jfxrt-in-fxrt-new,-check-jfxrt-in-fxsdk-jre" if="do.set.jfxrt.in.fxsdk.jre.old">
		        <property name="jfxrt.jar.location" value="${javafx.sdk}${file.separator}jre${file.separator}lib${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-set-jfxrt-in-fxsdk-jre-new" depends="-set-jfxrt-in-fxsdk-jre-old,-check-jfxrt-in-fxsdk-jre" if="do.set.jfxrt.in.fxsdk.jre.new">
		        <property name="jfxrt.jar.location" value="${javafx.sdk}${file.separator}jre${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-check-jfxrt-in-fxsdk-rt" depends="-check-property-javafx.sdk" if="javafx.sdk.defined">
		        <condition property="do.set.jfxrt.in.fxsdk.rt.old">
		            <and>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${javafx.sdk}${file.separator}rt${file.separator}lib${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		        <condition property="do.set.jfxrt.in.fxsdk.rt.new">
		            <and>
		                <not><isset property="do.set.jfxrt.in.fxsdk.rt.old"/></not>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${javafx.sdk}${file.separator}rt${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-jfxrt-in-fxsdk-rt-old" depends="-set-jfxrt-in-fxsdk-jre-new,-check-jfxrt-in-fxsdk-rt" if="do.set.jfxrt.in.fxsdk.rt.old">
		        <property name="jfxrt.jar.location" value="${javafx.sdk}${file.separator}rt${file.separator}lib${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-set-jfxrt-in-fxsdk-rt-new" depends="-set-jfxrt-in-fxsdk-rt-old,-check-jfxrt-in-fxsdk-rt" if="do.set.jfxrt.in.fxsdk.rt.new">
		        <property name="jfxrt.jar.location" value="${javafx.sdk}${file.separator}rt${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-check-jfxrt-in-platform-home-jre" if="platform.home">
		        <condition property="do.set.jfxrt.in.platform.home.jre.old">
		            <and>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${platform.home}${file.separator}jre${file.separator}lib${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		        <condition property="do.set.jfxrt.in.platform.home.jre.new">
		            <and>
		                <not><isset property="do.set.jfxrt.in.platform.home.jre.old"/></not>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${platform.home}${file.separator}jre${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-jfxrt-in-platform-home-jre-old" depends="-set-jfxrt-in-fxsdk-rt-new,-check-jfxrt-in-platform-home-jre" if="do.set.jfxrt.in.platform.home.jre.old">
		        <property name="jfxrt.jar.location" value="${platform.home}${file.separator}jre${file.separator}lib${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-set-jfxrt-in-platform-home-jre-new" depends="-set-jfxrt-in-platform-home-jre-old,-check-jfxrt-in-platform-home-jre" if="do.set.jfxrt.in.platform.home.jre.new">
		        <property name="jfxrt.jar.location" value="${platform.home}${file.separator}jre${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-check-jfxrt-in-platform-home-rt" if="platform.home">
		        <condition property="do.set.jfxrt.in.platform.home.rt.old">
		            <and>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${platform.home}${file.separator}rt${file.separator}lib${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		        <condition property="do.set.jfxrt.in.platform.home.rt.new">
		            <and>
		                <not><isset property="do.set.jfxrt.in.platform.home.rt.old"/></not>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${platform.home}${file.separator}rt${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-jfxrt-in-platform-home-rt-old" depends="-set-jfxrt-in-platform-home-jre-new,-check-jfxrt-in-platform-home-rt" if="do.set.jfxrt.in.platform.home.rt.old">
		        <property name="jfxrt.jar.location" value="${platform.home}${file.separator}rt${file.separator}lib${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-set-jfxrt-in-platform-home-rt-new" depends="-set-jfxrt-in-platform-home-rt-old,-check-jfxrt-in-platform-home-rt" if="do.set.jfxrt.in.platform.home.rt.new">
		        <property name="jfxrt.jar.location" value="${platform.home}${file.separator}rt${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-check-jfxrt-in-jre" unless="jfxrt.jar.location">
		        <condition property="do.set.jfxrt.in.jre.old">
		            <and>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${java.home}${file.separator}lib${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		        <condition property="do.set.jfxrt.in.jre.new">
		            <and>
		                <not><isset property="do.set.jfxrt.in.jre.old"/></not>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${java.home}${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-jfxrt-in-jre-old" depends="-set-jfxrt-in-platform-home-rt-new,-check-jfxrt-in-jre" if="do.set.jfxrt.in.jre.old">
		        <property name="jfxrt.jar.location" value="${java.home}${file.separator}lib${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-set-jfxrt-in-jre-new" depends="-set-jfxrt-in-jre-old,-check-jfxrt-in-jre" if="do.set.jfxrt.in.jre.new">
		        <property name="jfxrt.jar.location" value="${java.home}${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-check-jfxrt-in-envjdk-jre" unless="jfxrt.jar.location">
		        <property environment="env"/>
		        <condition property="do.set.jfxrt.in.envjdk.jre.old">
		            <and>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${env.JAVA_HOME}${file.separator}jre${file.separator}lib${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		        <condition property="do.set.jfxrt.in.envjdk.jre.new">
		            <and>
		                <not><isset property="do.set.jfxrt.in.envjdk.jre.old"/></not>
		                <not><isset property="jfxrt.jar.location"/></not>
		                <available file="${env.JAVA_HOME}${file.separator}jre${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-jfxrt-in-envjdk-jre-old" depends="-set-jfxrt-in-jre-new,-check-jfxrt-in-envjdk-jre" if="do.set.jfxrt.in.envjdk.jre.old">
		        <property name="jfxrt.jar.location" value="${env.JAVA_HOME}${file.separator}jre${file.separator}lib${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-set-jfxrt-in-envjdk-jre-new" depends="-set-jfxrt-in-envjdk-jre-old,-check-jfxrt-in-envjdk-jre" if="do.set.jfxrt.in.envjdk.jre.new">
		        <property name="jfxrt.jar.location" value="${env.JAVA_HOME}${file.separator}jre${file.separator}lib${file.separator}ext${file.separator}jfxrt.jar"/>
		    </target>
		    <target name="-pre-check-jfx-runtime" depends="-set-jfxrt-in-envjdk-jre-new">
		        <echo message="jfxrt.jar.location = ${jfxrt.jar.location}" level="verbose"/>
		    </target>
		
		    <target name="-check-jfx-runtime" depends="-check-jdk-version, -pre-check-jfx-runtime">
		        <condition property="jfx-runtime-available">
		            <and>
		                <or>
		                    <isset property="do.set.jfxrt.in.fxrt.old"/>
		                    <isset property="do.set.jfxrt.in.fxrt.new"/>
		                    <isset property="do.set.jfxrt.in.fxsdk.jre.old"/>
		                    <isset property="do.set.jfxrt.in.fxsdk.jre.new"/>
		                    <isset property="do.set.jfxrt.in.fxsdk.rt.old"/>
		                    <isset property="do.set.jfxrt.in.fxsdk.rt.new"/>
		                    <isset property="do.set.jfxrt.in.platform.home.jre.old"/>
		                    <isset property="do.set.jfxrt.in.platform.home.jre.new"/>
		                    <isset property="do.set.jfxrt.in.platform.home.rt.old"/>
		                    <isset property="do.set.jfxrt.in.platform.home.rt.new"/>
		                    <isset property="do.set.jfxrt.in.jre.old"/>
		                    <isset property="do.set.jfxrt.in.jre.new"/>
		                    <isset property="do.set.jfxrt.in.envjdk.jre.old"/>
		                    <isset property="do.set.jfxrt.in.envjdk.jre.new"/>
		                </or>
		                <isset property="jfxrt.jar.location"/>
		            </and>
		        </condition>
		        <fail message="Error:${line.separator}JavaFX runtime JAR not found." unless="jfx-runtime-available"/>
		        <echo message="jfx-runtime-available = ${jfx-runtime-available}" level="verbose"/>
		    </target>
		
		
		    <!-- Check availability of WebStart executable -->
		
		    <target name="-check-webstart-in-fxrt" depends="-check-property-javafx.runtime" if="javafx.runtime.defined">
		        <condition property="do.set.webstart.in.fxrt">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <isset property="javafx.runtime.defined"/>
		                <or>
		                    <available file="${javafx.runtime}${file.separator}bin${file.separator}javaws.exe"/>
		                    <available file="${javafx.runtime}${file.separator}bin${file.separator}javaws"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-webstart-in-fxrt" depends="-check-webstart-in-fxrt" if="do.set.webstart.in.fxrt">
		        <property name="active.webstart.executable" value="${javafx.runtime}${file.separator}bin${file.separator}javaws"/>
		    </target>
		    <target name="-check-webstart-in-fxsdk-jre" depends="-check-property-javafx.sdk" if="javafx.sdk.defined">
		        <condition property="do.set.webstart.in.fxsdk.jre">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <isset property="javafx.sdk.defined"/>
		                <or>
		                    <available file="${javafx.sdk}${file.separator}jre${file.separator}bin${file.separator}javaws.exe"/>
		                    <available file="${javafx.sdk}${file.separator}jre${file.separator}bin${file.separator}javaws"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-webstart-in-fxsdk-jre" depends="-set-webstart-in-fxrt,-check-webstart-in-fxsdk-jre" if="do.set.webstart.in.fxsdk.jre">
		        <property name="active.webstart.executable" value="${javafx.sdk}${file.separator}jre${file.separator}bin${file.separator}javaws"/>
		    </target>
		    <target name="-check-webstart-in-fxsdk" depends="-check-property-javafx.sdk" if="javafx.sdk.defined">
		        <condition property="do.set.webstart.in.fxsdk">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <isset property="javafx.sdk.defined"/>
		                <or>
		                    <available file="${javafx.sdk}${file.separator}bin${file.separator}javaws.exe"/>
		                    <available file="${javafx.sdk}${file.separator}bin${file.separator}javaws"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-webstart-in-fxsdk" depends="-set-webstart-in-fxsdk-jre,-check-webstart-in-fxsdk" if="do.set.webstart.in.fxsdk">
		        <property name="active.webstart.executable" value="${javafx.sdk}${file.separator}bin${file.separator}javaws"/>
		    </target>
		    <target name="-check-webstart-in-platform-home-jre" if="platform.home">
		        <condition property="do.set.webstart.in.platform.home.jre">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <or>
		                    <available file="${platform.home}${file.separator}jre${file.separator}bin${file.separator}javaws.exe"/>
		                    <available file="${platform.home}${file.separator}jre${file.separator}bin${file.separator}javaws"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-webstart-in-platform-home-jre" depends="-set-webstart-in-fxsdk,-check-webstart-in-platform-home-jre" if="do.set.webstart.in.platform.home.jre">
		        <property name="active.webstart.executable" value="${platform.home}${file.separator}jre${file.separator}bin${file.separator}javaws"/>
		    </target>
		    <target name="-check-webstart-in-platform-home" if="platform.home">
		        <condition property="do.set.webstart.in.platform.home">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <or>
		                    <available file="${platform.home}${file.separator}bin${file.separator}javaws.exe"/>
		                    <available file="${platform.home}${file.separator}bin${file.separator}javaws"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-webstart-in-platform-home" depends="-set-webstart-in-platform-home-jre,-check-webstart-in-platform-home" if="do.set.webstart.in.platform.home">
		        <property name="active.webstart.executable" value="${platform.home}${file.separator}bin${file.separator}javaws"/>
		    </target>
		    <target name="-check-webstart-in-jre" unless="active.webstart.executable">
		        <condition property="do.set.webstart.in.jre">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <or>
		                    <available file="${java.home}${file.separator}bin${file.separator}javaws.exe"/>
		                    <available file="${java.home}${file.separator}bin${file.separator}javaws"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-webstart-in-jre" depends="-set-webstart-in-platform-home,-check-webstart-in-jre" if="do.set.webstart.in.jre">
		        <property name="active.webstart.executable" value="${java.home}${file.separator}bin${file.separator}javaws"/>
		    </target>
		    <target name="-check-webstart-in-probjdk" unless="active.webstart.executable">
		        <condition property="do.set.webstart.in.probjdk">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <or>
		                    <available file="${java.home}${file.separator}..${file.separator}bin${file.separator}javaws.exe"/>
		                    <available file="${java.home}${file.separator}..${file.separator}bin${file.separator}javaws"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-webstart-in-probjdk" depends="-set-webstart-in-jre,-check-webstart-in-probjdk" if="do.set.webstart.in.probjdk">
		        <property name="active.webstart.executable" value="${java.home}${file.separator}..${file.separator}bin${file.separator}javaws"/>
		    </target>
		    <target name="-check-webstart-in-envjdk" unless="active.webstart.executable">
		        <property environment="env"/>
		        <condition property="do.set.webstart.in.envjdk">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <or>
		                    <available file="${env.JAVA_HOME}${file.separator}bin${file.separator}javaws.exe"/>
		                    <available file="${env.JAVA_HOME}${file.separator}bin${file.separator}javaws"/>
		                </or>
		            </and>
		        </condition>
		    </target>
		    <target name="-set-webstart-in-envjdk" depends="-set-webstart-in-probjdk,-check-webstart-in-envjdk" if="do.set.webstart.in.envjdk">
		        <property name="active.webstart.executable" value="${env.JAVA_HOME}${file.separator}bin${file.separator}javaws"/>
		    </target>
		    <target name="-pre-check-webstart-in-unix" depends="-check-operating-system,-set-webstart-in-envjdk" unless="active.webstart.executable">
		        <condition property="running.on.unix-active.webstart.executable">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <isset property="running.on.unix"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-check-webstart-in-unix" depends="-pre-check-webstart-in-unix" if="running.on.unix-active.webstart.executable">
		        <local name="exec.which.javaws.result"/>
		        <exec executable="command" failifexecutionfails="false" failonerror="false" resultproperty="exec.which.javaws.result" outputproperty="exec.which.javaws.output">
		            <arg line="-v javaws"/>
		        </exec>
		        <condition property="do.set.webstart.in.unix">
		            <and>
		                <not><isset property="active.webstart.executable"/></not>
		                <isset property="exec.which.javaws.result"/>
		                <equals arg1="${exec.which.javaws.result}" arg2="0"/>
		                <isset property="exec.which.javaws.output"/>
		                <not><equals arg1="${exec.which.javaws.output}" arg2=""/></not>
		            </and>
		        </condition>
		        <echo message="do.set.webstart.in.unix = ${do.set.webstart.in.unix}" level="verbose"/>
		    </target>
		    <target name="-set-webstart-in-unix" depends="-set-webstart-in-envjdk,-check-webstart-in-unix" if="do.set.webstart.in.unix">
		        <property name="active.webstart.executable" value="${exec.which.javaws.output}"/>
		    </target>
		    <target name="-pre-check-jfx-webstart" depends="-set-webstart-in-unix">
		        <echo message="active.webstart.executable = ${active.webstart.executable}" level="verbose"/>
		    </target>
		
		    <target name="-check-jfx-webstart" depends="-pre-check-jfx-webstart">
		        <condition property="jfx-webstart-available">
		            <and>
		                <or>
		                    <isset property="do.set.webstart.in.fxrt"/>
		                    <isset property="do.set.webstart.in.fxsdk.jre"/>
		                    <isset property="do.set.webstart.in.fxsdk"/>
		                    <isset property="do.set.webstart.in.platform.home.jre"/>
		                    <isset property="do.set.webstart.in.platform.home"/>
		                    <isset property="do.set.webstart.in.jre"/>
		                    <isset property="do.set.webstart.in.probjdk"/>
		                    <isset property="do.set.webstart.in.envjdk"/>
		                    <isset property="do.set.webstart.in.unix"/>
		                </or>
		                <isset property="active.webstart.executable"/>
		            </and>
		        </condition>
		        <condition property="jfx-webstart-missing+jdk7u6">
		            <and>
		                <not><isset property="jfx-webstart-available"/></not>
		                <not><isset property="have-jdk-pre7u6"/></not>
		            </and>
		        </condition>
		        <condition property="jfx-webstart-missing+javafx.runtime.missing+default">
		            <and>
		                <not><isset property="jfx-webstart-available"/></not>
		                <isset property="have-jdk-pre7u6"/>
		                <isset property="javafx.runtime.missing+default"/>
		            </and>
		        </condition>
		        <condition property="jfx-webstart-missing+javafx.runtime.missing-default">
		            <and>
		                <not><isset property="jfx-webstart-available"/></not>
		                <isset property="have-jdk-pre7u6"/>
		                <isset property="javafx.runtime.missing-default"/>
		            </and>
		        </condition>
		        <fail message="Error:${line.separator}WebStart executable could not be found in active JDK.${line.separator}Please check that the JDK is correctly installed and its version is at least 7u6." if="jfx-webstart-missing+jdk7u6"/>
		        <fail message="Error:${line.separator}WebStart executable could not be found.${line.separator}JavaFX RT path undefined. Check the definition of ${platform.active} in Java Platform Manager${line.separator}(or directly the properties platform.active and javafx.runtime in project.properties file).${line.separator}Note: If missing, the default JavaFX-enabled platform gets created automatically when creating a new JavaFX Project." if="jfx-webstart-missing+javafx.runtime.missing+default"/>
		        <fail message="Error:${line.separator}WebStart executable could not be found.${line.separator}JavaFX RT path undefined. Check the definition of ${platform.active} in Java Platform Manager${line.separator}(or directly the properties platform.active and javafx.runtime in project.properties file)." if="jfx-webstart-missing+javafx.runtime.missing-default"/>
		        <fail message="Error:${line.separator}WebStart executable could not be found." unless="jfx-webstart-available"/>
		        <echo message="jfx-webstart-available = ${jfx-webstart-available}" level="verbose"/>
		    </target>
		
		    
		    <!-- Legacy targets kept for compatibility with older build-impl.xml scripts -->
		
		    <!-- Note: target "-check-javafx" is not necessary any more but is referenced from NB 7.1 build-impl.xml -->
		    <target name="-check-javafx"/>
		    <!-- Note: target "-javafx-check-error" is not necessary any more but is referenced from NB 7.1 build-impl.xml -->
		    <target name="-javafx-check-error"/>    
		    <!-- Note: target "-init-javafx" is not necessary any more but is referenced from NB 7.1 build-impl.xml -->
		    <target name="-init-javafx"/>
		
		    
		    <!-- Check project properties -->
		    
		    <target name="-check-default-run-config" unless="config">
		        <property name="config" value="&lt;default config&gt;"/>
		    </target>
		    
		    <target name="-check-project">
		        <condition property="main-class-available">
		            <isset property="javafx.main.class"/>
		        </condition>
		        <condition property="vmargs-available">
		            <and>
		                <isset property="run.jvmargs"/>
		                <not><equals arg1="${run.jvmargs}" arg2=""/></not>
		            </and>
		        </condition>
		        <condition property="preloader-available">
		            <and>
		                <isset property="javafx.preloader.enabled"/>
		                <equals arg1="${javafx.preloader.enabled}" arg2="true"/>
		                <isset property="javafx.preloader.class"/>
		                <not><equals arg1="${javafx.preloader.class}" arg2=""/></not>
		                <isset property="javafx.preloader.jar.filename"/>
		                <not><equals arg1="${javafx.preloader.jar.filename}" arg2=""/></not>
		            </and>
		        </condition>
		        <condition property="app-with-preloader">
		            <and>
		                <istrue value="${preloader-available}"/>
		                <istrue value="${main-class-available}"/>
		            </and>
		        </condition>
		        <condition property="app-with-external-preloader-jar">
		            <and>
		                <isset property="app-with-preloader"/>
		                <isset property="javafx.preloader.type"/>
		                <equals arg1="${javafx.preloader.type}" arg2="jar" trim="true"/>
		            </and>
		        </condition>
		        <condition property="app-without-preloader">
		            <and>
		                <not>
		                    <istrue value="${preloader-available}"/>
		                </not>
		                <istrue value="${main-class-available}"/>
		            </and>
		        </condition>
		        <condition property="preloader-app">
		            <and>
		                <isset property="javafx.preloader"/>
		                <equals arg1="${javafx.preloader}" arg2="true"/>
		            </and>
		        </condition>
		        <condition property="fx-in-swing-app">
		            <and>
		                <isset property="javafx.swing"/>
		                <equals arg1="${javafx.swing}" arg2="true"/>
		            </and>
		        </condition>
		        <condition property="fx-in-swing-workaround-app">
		            <and>
		                <istrue value="${fx-in-swing-app}"/>
		                <istrue value="${preloader-app}"/>
		            </and>
		        </condition>
		        <condition property="preloader-app-no-workaround">
		            <and>
		                <istrue value="${preloader-app}"/>
		                <not><istrue value="${fx-in-swing-app}"/></not>
		            </and>
		        </condition>
		        <condition property="html-template-available">
		            <and>
		                <isset property="javafx.run.htmltemplate"/>
		                <not>
		                    <equals arg1="${javafx.run.htmltemplate}" arg2=""/>
		                </not>
		            </and>
		        </condition>
		        <condition property="icon-available">
		            <and>
		                <isset property="javafx.deploy.icon"/>
		                <not>
		                    <equals arg1="${javafx.deploy.icon}" arg2=""/>
		                </not>
		            </and>
		        </condition>
		        <condition property="dimensions-available">
		            <and>
		                <isset property="javafx.run.width"/>
		                <isset property="javafx.run.height"/>
		                <not><equals arg1="${javafx.run.width}" arg2=""/></not>
		                <not><equals arg1="${javafx.run.height}" arg2=""/></not>
		            </and>
		        </condition>
		        <condition property="update-mode-background">
		            <and>
		                <isset property="javafx.deploy.backgroundupdate"/>
		                <equals arg1="${javafx.deploy.backgroundupdate}" arg2="true" trim="true"/>
		            </and>
		        </condition>
		        <condition property="offline-allowed">
		            <and>
		                <isset property="javafx.deploy.allowoffline"/>
		                <equals arg1="${javafx.deploy.allowoffline}" arg2="true" trim="true"/>
		            </and>
		        </condition>
		        <condition property="permissions-elevated">
		            <and>
		                <isset property="javafx.deploy.permissionselevated"/>
		                <equals arg1="${javafx.deploy.permissionselevated}" arg2="true" trim="true"/>
		            </and>
		        </condition>
		        <condition property="binary-encode-css">
		            <and>
		                <isset property="javafx.binarycss"/>
		                <equals arg1="${javafx.binarycss}" arg2="true" trim="true"/>
		            </and>
		        </condition>
		        <condition property="rebase-lib-jars">
		            <and>
		                <isset property="javafx.rebase.libs"/>
		                <equals arg1="${javafx.rebase.libs}" arg2="true" trim="true"/>
		            </and>
		        </condition>
		        <condition property="use-blob-signing">
		            <and>
		                <isset property="javafx.signing.blob"/>
		                <equals arg1="${javafx.signing.blob}" arg2="true" trim="true"/>
		            </and>
		        </condition>
		        <echo message="main-class-available = ${main-class-available}" level="verbose"/>
		        <echo message="vmargs-available = ${vmargs-available}" level="verbose"/>
		        <echo message="preloader-available = ${preloader-available}" level="verbose"/>
		        <echo message="app-with-preloader = ${app-with-preloader}" level="verbose"/>
		        <echo message="app-with-preloader-without-project = ${app-with-preloader-without-project}" level="verbose"/>
		        <echo message="app-without-preloader = ${app-without-preloader}" level="verbose"/>
		        <echo message="preloader-app = ${preloader-app}" level="verbose"/>
		        <echo message="fx-in-swing-app = ${fx-in-swing-app}" level="verbose"/>
		        <echo message="fx-in-swing-workaround-app = ${fx-in-swing-workaround-app}" level="verbose"/>
		        <echo message="preloader-app-no-workaround = ${preloader-app-no-workaround}" level="verbose"/>
		        <echo message="html-template-available = ${html-template-available}" level="verbose"/>
		        <echo message="icon-available = ${icon-available}" level="verbose"/>
		        <echo message="dimensions-available = ${dimensions-available}" level="verbose"/>
		        <echo message="update-mode-background = ${update-mode-background}" level="verbose"/>
		        <echo message="offline-allowed = ${offline-allowed}" level="verbose"/>
		        <echo message="permissions-elevated = ${permissions-elevated}" level="verbose"/>
		        <echo message="binary-encode-css = ${binary-encode-css}" level="verbose"/>
		        <echo message="rebase-lib-jars = ${rebase-lib-jars}" level="verbose"/>
		        <echo message="use-blob-signing = ${use-blob-signing}" level="verbose"/>
		    </target>
		
		    <target name="-swing-api-check" depends="-check-project,-check-jfx-deployment" if="fx-in-swing-app">
		        <condition property="fx-in-swing-app-workaround">
		            <and>
		                <isset property="fx-in-swing-app"/>
		                <not><isset property="have-fx-ant-api-1.2"/></not>
		            </and>
		        </condition>
		    </target>
		    <target name="-swing-api-warning" depends="-swing-api-check" if="fx-in-swing-app-workaround">
		        <echo message="Info: No support for FX-in-Swing deployment detected in current JavaFX SDK. Using workaround instead."/>
		    </target>
		
		    <target name="-icon-deployment-check" depends="-check-project,-check-jfx-deployment" if="icon-available">
		        <condition property="icon-deployment-may-not-be-supported">
		            <and>
		                <isset property="icon-available"/>
		                <not><isset property="have-fx-ant-api-1.1"/></not>
		            </and>
		        </condition>
		    </target>
		    <target name="-icon-warning" depends="-icon-deployment-check" if="icon-deployment-may-not-be-supported">
		        <echo message="Warning: Note that due to a bug in early JavaFX 2.0 SDK distributions the icon may not be properly set in deployment files."/>
		    </target>
		
		    <target name="-set-dimensions" depends="-check-project" if="dimensions-available">
		        <property name="javafx.width" value="${javafx.run.width}"/>
		        <property name="javafx.height" value="${javafx.run.height}"/>
		    </target>
		    <target name="-reset-dimensions" depends="-check-project" unless="dimensions-available">
		        <property name="javafx.width" value="800"/>
		        <property name="javafx.height" value="600"/>
		    </target>
		
		    <target name="-set-update-mode-background" depends="-check-project" if="update-mode-background">
		        <property name="update-mode" value="background"/>
		    </target>
		    <target name="-set-update-mode-eager" depends="-check-project" unless="update-mode-background">
		        <property name="update-mode" value="eager"/>
		    </target>
		
		    <target name="-set-permissions-elevated" depends="-check-project" if="permissions-elevated">
		        <property name="permissions.elevated" value="true"/>
		    </target>
		    <target name="-reset-permissions-elevated" depends="-check-project" unless="permissions-elevated">
		        <property name="permissions.elevated" value="false"/>
		    </target>
		
		    <target name="-set-binary-css" depends="-check-project,-init-css-conversion" if="do.copy.binary.css">
		        <property name="css-include-ext" value="bss"/>
		        <property name="css-exclude-ext" value="css"/>
		    </target>
		    <target name="-unset-binary-css" depends="-check-project,-init-css-conversion" unless="do.copy.binary.css">
		        <property name="css-include-ext" value="css"/>
		        <property name="css-exclude-ext" value="bss"/>
		    </target>
		    <target name="-copy-binary-css" depends="-init-css-conversion,-set-binary-css,-unset-binary-css,-copy-binary-css-bypass,-copy-binary-css-impl"/>
		    <target name="-init-css-conversion" depends="-check-project,-check-ant-jre-version">
		        <fileset id="cssfiles" dir="${basedir}${file.separator}${build.classes.dir}">
		            <include name="**${file.separator}*.css"/>
		        </fileset>
		        <pathconvert refid="cssfiles" property="cssfileset.notempty" setonempty="false"/>
		        <condition property="do.copy.binary.css">
		            <and>
		                <isset property="binary-encode-css"/>
		                <isset property="cssfileset.notempty"/>
		                <not><isset property="have-jdk7-css2bin-bug"/></not>
		            </and>
		        </condition>
		        <condition property="do.bypass.binary.css">
		            <and>
		                <isset property="binary-encode-css"/>
		                <isset property="cssfileset.notempty"/>
		                <isset property="have-jdk7-css2bin-bug"/>
		            </and>
		        </condition>
		        <echo message="do.copy.binary.css = ${do.copy.binary.css}" level="verbose"/>
		        <echo message="do.bypass.binary.css = ${do.bypass.binary.css}" level="verbose"/>
		    </target>
		    <target name="-copy-binary-css-bypass" depends="-init-css-conversion" if="do.bypass.binary.css">
		        <echo message="Warning: Bypassing FX CSS to BSS conversion due to a bug in &lt;fx:csstobin&gt; task in current JDK platform" level="warning"/>
		    </target>
		    <target name="-copy-binary-css-impl" depends="-init-css-conversion" if="do.copy.binary.css">
		        <property name="cssfileslist" refid="cssfiles"/>
		        <echo message="css files to binary convert: " level="verbose">${cssfileslist}</echo>
		        <fx:csstobin outdir="${basedir}${file.separator}${build.classes.dir}">
		            <fileset refid="cssfiles"/>
		        </fx:csstobin>
		    </target>
		
		
		    <!-- Copy dependent libraries -->
		    
		    <!-- Note: target "-jfx-copylibs" is referenced from NB 7.1 build-impl.xml -->
		    <target name="-jfx-copylibs" depends="init,compile,-pre-pre-jar,-pre-jar,-jfx-copylibs-warning" unless="fallback.no.javascript">
		        <jfx-copylibs-js-impl/>
		    </target>
		    <target name="-jfx-copylibs-warning" if="fallback.no.javascript">
		        <echo message="Warning: Dependent Libraries copy (-jfx-copylibs) skipped in fallback build mode due to JDK missing JavaScript support."/>
		    </target>
		    <macrodef name="jfx-copylibs-js-impl">
		        <sequential>
		            <local name="run.classpath.without.build.classes.and.dist.dir"/>
		            <pathconvert property="run.classpath.without.build.classes.and.dist.dir">
		                <path path="${run.classpath}"/>
		                <map from="${basedir}${file.separator}${build.classes.dir}" to=""/>
		                <map from="${basedir}${file.separator}${dist.jar}" to=""/>
		                <scriptmapper language="javascript">
		                    self.addMappedName(
		                        (source.indexOf("jfxrt.jar") >= 0) ||
		                        (source.indexOf("deploy.jar") >= 0) ||
		                        (source.indexOf("javaws.jar") >= 0) ||
		                        (source.indexOf("plugin.jar") >= 0)
		                        ? "" : source
		                    );
		                </scriptmapper>
		            </pathconvert>
		            <!-- add possibly missing dependencies at distance 2 (build system logic thus provides transitive closure) -->
		            <local name="run.and.lib.classpath"/>
		            <echo message="JavaScript: -jfx-copylibs" level="verbose"/>
		            <script language="javascript">
		                <![CDATA[
		                    function prefix(s, len) {
		                        if(s == null || len <= 0 || s.length == 0) {
		                            return new String("");
		                        }
		                        return new String(s.substr(0, len));
		                    }
		                    function defined(s) {
		                        return (s != null) && (s != "null") && (s.length > 0);
		                    }
		                    var pathConvert = project.createTask("pathconvert");
		                    pathConvert.setProperty("run.and.lib.classpath");
		                    var classPath = new String(project.getProperty("run.classpath.without.build.classes.and.dist.dir"));
		                    var fileSeparator = new String(project.getProperty("file.separator"));
		                    if(defined(classPath)) {
		                        var classPathCopy = pathConvert.createPath();
		                        classPathCopy.setPath(classPath);
		                        var pathArray;
		                        if(classPath.indexOf(";") != -1) {
		                            pathArray = classPath.split(";");
		                        } else {
		                            pathArray = classPath.split(":");
		                        }
		                        var added = new java.lang.StringBuilder();
		                        for (var i = 0; i < pathArray.length; i++) {
		                            var index = pathArray[i].lastIndexOf(fileSeparator);
		                            if (index >= 0) {
		                                var onePath = prefix(pathArray[i], index+1).concat("lib");
		                                var oneDir = new java.io.File(onePath);
		                                if(oneDir.exists()) {
		                                    var fs = project.createDataType( "fileset" );
		                                    fs.setDir( oneDir );
		                                    fs.setIncludes("*.jar");
		                                    var ds = fs.getDirectoryScanner(project);
		                                    var srcFiles = ds.getIncludedFiles();
		                                    for (var j = 0; j < srcFiles.length; j++) {
		                                        if(classPath.indexOf( srcFiles[j] ) == -1 && added.indexOf( srcFiles[j] ) == -1) {
		                                            var path = pathConvert.createPath();
		                                            path.setPath( onePath.concat(fileSeparator).concat(srcFiles[j]) );
		                                            added.append( srcFiles[j] );
		                                        }
		                                    }
		                                }
		                            }
		                        }
		                    }
		                    pathConvert.perform();
		                ]]>
		            </script>
		            <echo message="run.and.lib.classpath = ${run.and.lib.classpath}" level="verbose"/>
		            <delete dir="${dist.dir}${file.separator}lib" includeEmptyDirs="true" quiet="true"/>
		            <copy todir="${dist.dir}${file.separator}lib" flatten="true" preservelastmodified="true" overwrite="true">
		                <path>
		                    <pathelement path="${run.and.lib.classpath}"/>
		                </path>
		            </copy>
		        </sequential>
		    </macrodef>
		    
		    <target name="-copy-external-preloader-jar" depends="-check-project" if="app-with-external-preloader-jar">
		        <copy file="${javafx.preloader.jar.path}" todir="${dist.dir}${file.separator}lib"/>
		    </target>
		
		
		    <!-- Optional classpath re-base of dependent JAR manifests after copy to lib/, required by GlassFish -->
		
		    <!-- Note: target "-rebase-libs" is referenced from NB 7.1 build-impl.xml -->
		    <target name="-rebase-libs" depends="-check-project, -jfx-copylibs, -check-rebase-libs, -rebase-libs-warning" if="do-rebase-lib-jars">
		        <rebase-libs-js-impl/>
		    </target>
		    <target name="-check-rebase-libs">
		        <condition property="do-rebase-lib-jars">
		            <and>
		                <isset property="rebase-lib-jars"/>
		                <not><isset property="fallback.no.javascript"/></not>
		            </and>
		        </condition>
		        <condition property="do-skip-rebase-libs">
		            <and>
		                <isset property="rebase-lib-jars"/>
		                <isset property="fallback.no.javascript"/>
		            </and>
		        </condition>
		    </target>
		    <target name="-rebase-libs-warning" depends="-check-rebase-libs" if="do-skip-rebase-libs">
		        <echo message="Warning: Dependent Libraries JARs rebase (-rebase-libs) skipped in fallback build mode due to JDK missing JavaScript support."/>
		    </target>
		
		    <macrodef name="rebase-libs-js-impl">
		        <sequential>
		            <property name="pp_rebase_dir" value="${basedir}${file.separator}${dist.dir}${file.separator}lib"/>
		            <property name="pp_rebase_fs" value="*.jar"/>
		            <echo message="JavaScript: -rebase-libs-js-impl" level="verbose"/>
		            <script language="javascript">
		                <![CDATA[
		                    var dir = new String(project.getProperty("pp_rebase_dir"));
		                    var fDir = new java.io.File(dir);
		                    if( fDir.exists() ) {
		                        var callTask = project.createTask("antcall");
		                        callTask.setTarget("-rebase-libs-macro-call");
		                        var param = callTask.createParam();
		                        param.setName("jar.file.to.rebase");
		                        var includes = new String(project.getProperty("pp_rebase_fs"));
		                        var fs = project.createDataType("fileset");
		                        fs.setDir( fDir );
		                        fs.setIncludes(includes);
		                        var ds = fs.getDirectoryScanner(project);
		                        var srcFiles = ds.getIncludedFiles();
		                        for (var i = 0; i < srcFiles.length; i++) {
		                            param.setValue(dir.concat("${file.separator}").concat(srcFiles[i]));
		                            callTask.perform();
		                        }
		                    }
		                ]]>
		            </script>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="rebase-lib">
		        <attribute name="jarfile"/>
		        <sequential>
		            <local name="tmpdir"/>
		            <property name="tmpdir" value="${java.io.tmpdir}${file.separator}${user.name}_${ant.project.name}_rebase" />
		            <echo message="tmpdir = ${tmpdir}" level="verbose"/>
		            <delete dir="${tmpdir}" quiet="true"/>
		            <mkdir dir="${tmpdir}"/>
		            <unzip src="@{jarfile}" dest="${tmpdir}">
		                <patternset>
		                    <include name="META-INF${file.separator}MANIFEST.MF"/>
		                </patternset>
		            </unzip>
		            <local name="manifest.file.temp"/>
		            <property name="manifest.file.temp" value="${tmpdir}${file.separator}META-INF${file.separator}MANIFEST.MF" />
		            <echo message="manifest.file.temp = ${manifest.file.temp}" level="verbose"/>
		            <!-- edited manifest file -->
		            <local name="manifest.file.temp.new"/>
		            <property name="manifest.file.temp.new" value="${manifest.file.temp}_new" />
		            <echo message="manifest.file.temp.new = ${manifest.file.temp.new}" level="verbose"/>
		            <echo message="JavaScript: rebase-lib" level="verbose"/>
		            <script language="javascript">
		                <![CDATA[
		                    var UTF_8 = "UTF-8";
		                    var ATTR_CLASS_PATH = "Class-Path";
		                    var ATTR_CLASS_PATH_FX = "JavaFX-Class-Path";
		                    function endsWith(s, suffix) {
		                        var i = s.lastIndexOf(suffix);
		                        return  (i != -1) && (i == (s.length - suffix.length));
		                    }
		                    function isSigned(manifest) {        
		                        var sections = manifest.getSectionNames();
		                        while(sections.hasMoreElements()) {
		                            var sectionname = new String(sections.nextElement());
		                            var section = manifest.getSection(sectionname);
		                            if(section != null) {
		                                var sectionKeys = section.getAttributeKeys();
		                                while (sectionKeys.hasMoreElements()) {
		                                    var element = new String(sectionKeys.nextElement());
		                                    if (endsWith(element, "-Digest") || endsWith(element, "-digest")) {
		                                        return true;
		                                    }
		                                }
		                            }
		                        }
		                        return false;
		                    }
		                    var src = new String(project.getProperty("manifest.file.temp"));
		                    var srf = new java.io.File(src);
		                    var manifest;
		                    try {
		                        var fis = new java.io.FileInputStream(srf);
		                        try {
		                            var isr = new java.io.InputStreamReader(fis, UTF_8);
		                            try {
		                                manifest = new org.apache.tools.ant.taskdefs.Manifest(isr);
		                            } finally {
		                                isr.close();
		                            }
		                        } finally {
		                            fis.close();
		                        }
		                    } catch(e) {
		                        manifest = null;
		                    }
		                    if(manifest != null) {
		                        if(isSigned(manifest)) {
		                            print("Warning: Signed JAR can not be rebased.");
		                        } else {
		                            var mainSection = manifest.getMainSection();
		                            var classPath = mainSection.getAttributeValue(ATTR_CLASS_PATH);
		                            var classPathAttr = null;
		                            if (classPath != null) {
		                                classPathAttr = ATTR_CLASS_PATH;
		                            } else {
		                                classPath = mainSection.getAttributeValue(ATTR_CLASS_PATH_FX);
		                                if(classPath != null) {
		                                    classPathAttr = ATTR_CLASS_PATH_FX;
		                                }
		                            }
		                            if(classPath != null) {
		                                var result = new java.lang.StringBuilder();
		                                var changed = false;
		                                var pathArray = classPath.split(" ");
		                                for (var i = 0; i < pathArray.length; i++) {
		                                    if (result.length() > 0) {
		                                        result.append(' ');
		                                    }
		                                    var index = pathArray[i].lastIndexOf('/');
		                                    if (index >= 0 && index < pathArray[i].length - 1) {
		                                        pathArray[i] = pathArray[i].substring(index+1);
		                                        changed = true;
		                                    }
		                                    result.append(pathArray[i]);
		                                }
		                                mainSection.removeAttribute(classPathAttr);
		                                mainSection.addAttributeAndCheck(new org.apache.tools.ant.taskdefs.Manifest.Attribute(classPathAttr, result.toString()));
		                                var tgt = new String(project.getProperty("manifest.file.temp.new"));
		                                var tgf = new java.io.File(tgt);
		                                try {
		                                    var fos = new java.io.FileOutputStream(tgf);
		                                    try {
		                                        var osw = new java.io.OutputStreamWriter(fos, UTF_8);
		                                        try {
		                                            var manifestOut = new java.io.PrintWriter(osw);
		                                            manifest.write(manifestOut);
		                                            manifestOut.close();
		                                        } finally {
		                                            osw.close();
		                                        }
		                                    } finally {
		                                        fos.close();
		                                    }
		                                } catch(e) {
		                                    print("Warning: problem storing rebased manifest file.");
		                                }
		                            }
		                        }
		                    }
		                ]]>
		            </script>
		            <antcall target="-move-new-manifest-if-exists">
		                <param name="move.file.from" value="${manifest.file.temp.new}"/>
		                <param name="move.file.to" value="${manifest.file.temp}"/>
		            </antcall>
		            <zip destfile="@{jarfile}" basedir="${tmpdir}" update="true"/>
		            <delete dir="${tmpdir}" quiet="true"/>
		        </sequential>
		    </macrodef>
		    
		    <target name="-new-temp-mainfest-existence">
		        <condition property="new-temp-manifest-exists">
		            <available file="${move.file.from}"/>
		        </condition>
		        <echo message="new-temp-manifest-exists = ${new-temp-manifest-exists}" level="verbose"/>
		    </target>
		    
		    <target name="-move-new-manifest-if-exists" depends="-new-temp-mainfest-existence" if="new-temp-manifest-exists">
		        <move file="${move.file.from}" tofile="${move.file.to}" failonerror="false"/>
		    </target>
		    
		    <target name="-rebase-libs-macro-call">
		        <echo message="Rebase jarfile = ${jar.file.to.rebase}" level="verbose"/>
		        <rebase-lib jarfile="${jar.file.to.rebase}"/>
		    </target>
		    
		
		    <!-- Main Deployment Target -->
		
		    <!-- Note: target "jfx-deployment" is referenced from NB 7.1+ build-impl.xml -->
		    <target name="jfx-deployment" depends="-check-jfx-deployment-launch,-do-jfx-deployment-script,-do-jfx-deployment-noscript" if="jfx-deployment-available"/>
		
		    <target name="-check-dist-lib-exists">
		        <deploy-defines/>
		        <available file="${jfx.deployment.dir}${file.separator}lib" type="dir" property="dist.lib.exists"/>
		    </target>
		    <target name="-check-jfx-deployment-jar-current-nolib" depends="-check-dist-lib-exists" unless="dist.lib.exists">
		        <uptodate property="jfx-deployment-jar-current" targetfile="${jfx.deployment.dir}${file.separator}${jfx.deployment.jar}" >
		            <srcfiles dir="${basedir}${file.separator}${build.classes.dir}" includes="**${file.separator}*"/>
		            <srcfiles dir="${basedir}${file.separator}nbproject" includes="**${file.separator}*"/>
		        </uptodate>
		    </target>
		    <target name="-check-jfx-deployment-jar-current-lib" depends="-check-dist-lib-exists" if="dist.lib.exists">
		        <uptodate property="jfx-deployment-jar-current" targetfile="${jfx.deployment.dir}${file.separator}${jfx.deployment.jar}" >
		            <srcfiles dir="${basedir}${file.separator}${build.classes.dir}" includes="**${file.separator}*"/>
		            <srcfiles dir="${jfx.deployment.dir}${file.separator}lib" includes="**${file.separator}*"/>
		            <srcfiles dir="${basedir}${file.separator}nbproject" includes="**${file.separator}*"/>
		        </uptodate>
		    </target>
		    <target name="-check-jfx-deployment-launch" depends="-check-jfx-deployment,-check-jfx-deployment-jar-current-nolib,-check-jfx-deployment-jar-current-lib">
		        <condition property="do-jfx-deployment-script">
		            <and>
		                <isset property="jfx-deployment-available"/>
		                <not><isset property="fallback.no.javascript"/></not>
		                <not><isset property="jfx-deployment-jar-current"/></not>
		            </and>
		        </condition>
		        <condition property="do-jfx-deployment-noscript">
		            <and>
		                <isset property="jfx-deployment-available"/>
		                <isset property="fallback.no.javascript"/>
		                <not><isset property="jfx-deployment-jar-current"/></not>
		            </and>
		        </condition>
		    </target>
		    <target name="-do-jfx-deployment-script" depends="-check-jfx-deployment-launch" if="do-jfx-deployment-script">
		        <antcall target="jfx-deployment-script"/>
		    </target>
		    <target name="-do-jfx-deployment-noscript" depends="-check-jfx-deployment-launch" if="do-jfx-deployment-noscript">
		        <antcall target="jfx-deployment-noscript"/>
		    </target>
		
		    <target name="jfx-deployment-script" depends="-check-jfx-deployment,-check-project,
		        -swing-api-warning,-icon-warning,
		        -set-dimensions,-reset-dimensions,-set-update-mode-background,-set-update-mode-eager,
		        -set-permissions-elevated,-reset-permissions-elevated,
		        -copy-external-preloader-jar,-copy-binary-css,
		        -deploy-app-sign-nopreloader-notemplate,
		        -deploy-app-sign-preloader-notemplate,
		        -deploy-app-sign-nopreloader-template,
		        -deploy-app-sign-preloader-template,
		        -deploy-app-sign-nopreloader-notemplate-swing,
		        -deploy-app-sign-nopreloader-template-swing,
		        -deploy-app-sign-blob-nopreloader-notemplate,
		        -deploy-app-sign-blob-preloader-notemplate,
		        -deploy-app-sign-blob-nopreloader-template,
		        -deploy-app-sign-blob-preloader-template,
		        -deploy-app-sign-blob-nopreloader-notemplate-swing,
		        -deploy-app-sign-blob-nopreloader-template-swing,
		        -deploy-app-nosign-nopreloader-notemplate,
		        -deploy-app-nosign-preloader-notemplate,
		        -deploy-app-nosign-nopreloader-template,
		        -deploy-app-nosign-preloader-template,
		        -deploy-app-nosign-nopreloader-notemplate-swing,
		        -deploy-app-nosign-nopreloader-template-swing"
		        if="jfx-deployment-available">
		    </target>
		
		    <target name="jfx-deployment-noscript" depends="-check-jfx-deployment,-check-project,
		        -swing-api-warning,-icon-warning,
		        -set-dimensions,-reset-dimensions,-set-update-mode-background,-set-update-mode-eager,
		        -set-permissions-elevated,-reset-permissions-elevated,
		        -copy-external-preloader-jar,-copy-binary-css,
		        -fallback-deploy-app-sign-nopreloader-notemplate,
		        -fallback-deploy-app-sign-preloader-notemplate,
		        -fallback-deploy-app-sign-nopreloader-template,
		        -fallback-deploy-app-sign-preloader-template,
		        -fallback-deploy-app-sign-nopreloader-notemplate-swing,
		        -fallback-deploy-app-sign-nopreloader-template-swing,
		        -fallback-deploy-app-sign-blob-nopreloader-notemplate,
		        -fallback-deploy-app-sign-blob-preloader-notemplate,
		        -fallback-deploy-app-sign-blob-nopreloader-template,
		        -fallback-deploy-app-sign-blob-preloader-template,
		        -fallback-deploy-app-sign-blob-nopreloader-notemplate-swing,
		        -fallback-deploy-app-sign-blob-nopreloader-template-swing,
		        -fallback-deploy-app-nosign-nopreloader-notemplate,
		        -fallback-deploy-app-nosign-preloader-notemplate,
		        -fallback-deploy-app-nosign-nopreloader-template,
		        -fallback-deploy-app-nosign-preloader-template,
		        -fallback-deploy-app-nosign-nopreloader-notemplate-swing,
		        -fallback-deploy-app-nosign-nopreloader-template-swing"
		        if="jfx-deployment-available">
		    </target>
		
		
		    <!-- Security / Signing -->
		    
		    <target name="-unavailable-signjars-task" depends="-check-jfx-deployment" unless="jfx-deployment-available">
		        <echo message="Warning: Task required to sign JAR file is missing, check the availability of JavaFX 2.0 deployment tasks. JAR files will not be signed."/>
		    </target>
		
		    <target name="-security-props-check">
		        <condition property="javafx.signed.true">
		            <istrue value="${javafx.signing.enabled}"/>
		        </condition>
		    </target>
		
		    <target name="-check-signing-possible" depends="-security-props-check,-check-jfx-deployment,-unavailable-signjars-task">
		        <condition property="javafx.signed.true+signjars.task.available">
		            <and>
		                <isset property="javafx.signed.true"/>
		                <isset property="jfx-deployment-available"/>
		            </and>
		        </condition>
		    </target>
		    
		    <target name="-javafx-init-keystore" depends="-check-signing-possible,-javafx-init-signing,-javafx-init-keystore1,-javafx-init-keystore2,-check-keystore-exists" 
		            if="javafx.signed.true+signjars.task.available" unless="do.not.init.keystore">
		        <property name="javafx.signjar.vendor" value="CN=${application.vendor}"/>
		        <echo message="Going to create default keystore in ${javafx.signjar.keystore}"/>
		        <genkey dname="${javafx.signjar.vendor}" alias="${javafx.signjar.alias}" keystore="${javafx.signjar.keystore}"
		            storepass="${javafx.signjar.storepass}" keypass="${javafx.signjar.keypass}"/>
		    </target>
		    
		    <target name="-check-keystore-exists" depends="-security-props-check">
		        <available property="javafx.signjar.keystore.exists" file="${javafx.signjar.keystore}"/>
		        <condition property="do.not.init.keystore">
		            <or>
		                <not><isset property="javafx.signed.true"/></not>
		                <isset property="javafx.signjar.keystore.exists"/>
		            </or>
		        </condition>
		    </target>
		
		    <target name="-javafx-init-signing">
		        <condition property="generated.key.signing">
		            <equals arg1="${javafx.signing.type}" arg2="self" trim="true"/>
		        </condition>
		    </target>
		
		    <target name="-javafx-init-keystore1" depends="-javafx-init-signing" if="generated.key.signing">
		        <property name="javafx.signjar.keystore" value="${basedir}${file.separator}build${file.separator}nb-jfx.jks" />
		        <property name="javafx.signjar.storepass" value="storepass"/>
		        <property name="javafx.signjar.keypass" value="keypass"/>
		        <property name="javafx.signjar.alias" value="nb-jfx"/>
		    </target>
		
		    <target name="-javafx-init-keystore2" depends="-javafx-init-signing" unless="generated.key.signing">
		        <property name="javafx.signjar.keystore" value="${javafx.signing.keystore}" />
		        <property name="javafx.signjar.storepass" value="${javafx.signing.keystore.password}"/>
		        <property name="javafx.signjar.keypass" value="${javafx.signing.keyalias.password}"/>
		        <property name="javafx.signjar.alias" value="${javafx.signing.keyalias}"/>
		    </target>
		
		    <target name="-check-signing-security" depends="-security-props-check">
		        <condition property="is.signing.unsafe">
		            <or>
		                <not><isset property="javafx.signed.true"/></not>
		                <not><equals arg1="${javafx.signing.type}" arg2="key" casesensitive="false" trim="true"/></not>
		            </or>
		        </condition>
		    </target>
		
		    <target name="-warn-insufficient-signing" depends="-check-signing-security" if="is.signing.unsafe">
		        <echo message="Warning: Unsigned and self-signed WebStart Applications and Applets are deprecated from JDK7u21 onwards due to security reasons.${line.separator}         To ensure future correct functionality please sign WebStart Applications and Applets using trusted certificate."/>
		    </target>
		
		    
		    <!-- Project Deployment Macros -->
		
		    <macrodef name="deploy-defines">
		        <sequential>
		            <basename property="jfx.deployment.jar" file="${dist.jar}"/>
		            <property name="jfx.deployment.dir" location="${dist.dir}"/>
		        </sequential>
		    </macrodef>
		
		    <macrodef name="deploy-preprocess">
		        <sequential>
		            <delete includeEmptyDirs="true" quiet="true">
		                <fileset dir="${jfx.deployment.dir}${file.separator}lib">
		                    <exclude name="**${file.separator}*.jar"/>
		                </fileset>
		            </delete>
		        </sequential>
		    </macrodef>
		
		    <!-- fx:jar scripted call enables passing of arbitrarily long list of params and fx-version dependent behavior -->
		    <macrodef name="deploy-jar">
		        <sequential>
		            <antcall target="-pre-jfx-jar"/>
		            <echo message="javafx.ant.classpath = ${javafx.ant.classpath}" level="verbose"/>
		            <typedef name="fx_jar" classname="com.sun.javafx.tools.ant.FXJar" classpath="${javafx.ant.classpath}"/>
		            <echo message="Launching &lt;fx:jar&gt; task from ${ant-javafx.jar.location}" level="info"/>
		            <property name="pp_jar_destfile" value="${jfx.deployment.dir}${file.separator}${jfx.deployment.jar}"/>
		            <property name="pp_jar_buildclasses" value="${basedir}${file.separator}${build.classes.dir}"/>
		            <property name="pp_jar_cssbss" value="**${file.separator}*.${css-exclude-ext}"/>
		            <property name="pp_jar_dir" value="${jfx.deployment.dir}"/>
		            <property name="pp_jar_fs1" value="lib${file.separator}${javafx.preloader.jar.filename}"/>
		            <property name="pp_jar_fs2" value="lib${file.separator}*.jar"/>
		            <echo message="deploy_jar: pp_jar_destfile = ${pp_jar_destfile}" level="verbose"/>
		            <echo message="deploy_jar: pp_jar_buildclasses = ${pp_jar_buildclasses}" level="verbose"/>
		            <echo message="deploy_jar: pp_jar_cssbss = ${pp_jar_cssbss}" level="verbose"/>
		            <echo message="deploy_jar: pp_jar_dir = ${pp_jar_dir}" level="verbose"/>
		            <echo message="deploy_jar: pp_jar_fs1 = ${pp_jar_fs1}" level="verbose"/>
		            <echo message="deploy_jar: pp_jar_fs2 = ${pp_jar_fs2}" level="verbose"/>
		            <echo message="JavaScript: deploy-jar" level="verbose"/>
		            <script language="javascript">
		                <![CDATA[
		                    function isTrue(prop) {
		                        return prop != null &&
		                           ( prop.toLowerCase() == "true" || prop.toLowerCase() == "yes" || prop.toLowerCase() == "on" );
		                    }                    
		                    function prefix(s, len) {
		                        if(s == null || len <= 0 || s.length == 0) {
		                            return new String("");
		                        }
		                        return new String(s.substr(0, len));
		                    }
		                    function replaceSuffix(s, os, ns) {
		                        return prefix(s, s.indexOf(os)).concat(ns);
		                    }
		                    function startsWith(s, prefix) {
		                        return (s != null) && (s.indexOf(prefix) == 0);
		                    }
		                    function endsWith(s, suffix) {
		                        var i = s.lastIndexOf(suffix);
		                        return  (i != -1) && (i == (s.length - suffix.length));
		                    }
		                    function defined(s) {
		                        return (s != null) && (s != "null") && (s.length > 0);
		                    }
		                    function contains(array, prop) {
		                        for (var i = 0; i < array.length; i++) {
		                            var s1 = new String(array[i]);
		                            var s2 = new String(prop);
		                            if( s1.toLowerCase() == s2.toLowerCase() ) {
		                                return true;
		                            }
		                        }
		                        return false;
		                    }
		                    var S = new String(java.io.File.separator);
		                    var JFXPAR = "javafx.param";
		                    var JFXMAN = "javafx.manifest.entry";
		                    var JFXPARN = "name";
		                    var JFXPARV = "value";
		                    var JFXPARH = "hidden";
		                    var JFXLAZY = "download.mode.lazy.jar";
		                    var withpreloader = new String(project.getProperty("app-with-preloader"));
		                    var fx_ant_api_1_1 = new String(project.getProperty("have-fx-ant-api-1.1"));
		                    var fx_ant_api_1_2 = new String(project.getProperty("have-fx-ant-api-1.2"));
		                    var fx_in_swing_app = new String(project.getProperty("fx-in-swing-app"));
		
		                    // get jars with lazy download mode property set
		                    function getLazyJars() {
		                        var jars = new Array();
		                        var keys = project.getProperties().keys();
		                        while(keys.hasMoreElements()) {
		                            var pn = new String(keys.nextElement());
		                            if(startsWith(pn, JFXLAZY)) {
		                                var fname = new String(pn.substring(JFXLAZY.length+1));
		                                jars.push(fname);
		                            }
		                        }
		                        return jars.length > 0 ? jars : null;
		                    }
		                    // set download mode of dependent libraries
		                    function setDownloadMode(fsEager, fsLazy, jars) {
		                        for(var i = 0; i < jars.length; i++) {
		                            fsEager.setExcludes("lib" + S + jars[i]);
		                            fsLazy.setIncludes("lib" + S + jars[i]);
		                        }
		                    }
		                    
		                    // fx:jar
		                    var jar = project.createTask("fx_jar");
		                    jar.setProject(project);
		                    var destfile = new String(project.getProperty("pp_jar_destfile"));
		                    jar.setDestfile(destfile);
		
		                    // fx:application
		                    var app = jar.createApplication();
		                    app.setProject(project);
		                    var title = new String(project.getProperty("application.title"));
		                    var mainclass;
		                    if(isTrue(fx_in_swing_app) && isTrue(fx_ant_api_1_2)) {
		                        mainclass = new String(project.getProperty("main.class"));
		                        app.setToolkit("swing");
		                    } else {
		                        mainclass = new String(project.getProperty("javafx.main.class"));
		                    }
		                    var fallback = new String(project.getProperty("javafx.fallback.class"));
		                    app.setName(title);
		                    app.setMainClass(mainclass);
		                    app.setFallbackClass(fallback);
		                    if(isTrue(withpreloader)) {
		                        preloaderclass = new String(project.getProperty("javafx.preloader.class"));
		                        app.setPreloaderClass(preloaderclass);
		                    }
		                    var appversion = new String(project.getProperty("javafx.application.implementation.version"));
		                    if(defined(appversion)) {
		                        app.setVersion(appversion);
		                    } else {
		                        app.setVersion("1.0");
		                    }
		                    // fx:param, fx:argument
		                    var searchHides = project.getProperties().keys();
		                    var hides = new Array();
		                    while(searchHides.hasMoreElements()) {
		                        // collect all hidden property names
		                        var pns = new String(searchHides.nextElement());
		                        if(startsWith(pns, JFXPAR) && endsWith(pns, JFXPARN)) {
		                            var propns = new String(project.getProperty(pns));
		                            var phs = replaceSuffix(pns, JFXPARN, JFXPARH);
		                            var proph = new String(project.getProperty(phs));
		                            if(isTrue(proph)) {
		                                hides.push(propns);
		                            }
		                         }
		                    }
		                    var keys = project.getProperties().keys();
		                    while(keys.hasMoreElements()) {
		                        var pn = new String(keys.nextElement());
		                        if(startsWith(pn, JFXPAR) && endsWith(pn, JFXPARN)) {
		                            var propn = new String(project.getProperty(pn));
		                            if(defined(propn) && !contains(hides, propn)) {
		                                var pv = replaceSuffix(pn, JFXPARN, JFXPARV);
		                                var propv = new String(project.getProperty(pv));
		                                if(defined(propv)) {
		                                    var par = app.createParam();
		                                    par.setName(propn);
		                                    par.setValue(propv);
		                                } else {
		                                    if(isTrue(fx_ant_api_1_1)) {
		                                        var arg = app.createArgument();
		                                        arg.addText(propn);
		                                    } else {
		                                        print("Warning: Unnamed parameters not supported by this version of JavaFX SDK deployment Ant tasks. Upgrade JavaFX to 2.0.2 or higher.");
		                                    }
		                                }
		                            }
		                        }
		                    }
		                    
		                    // fx:resources
		                    var res = jar.createResources();
		                    res.setProject(project);
		                    var pdir = new String(project.getProperty("pp_jar_dir"));
		                    if(isTrue(withpreloader)) {
		                        var f1 = res.createFileSet();
		                        f1.setProject(project);
		                        f1.setDir(new java.io.File(pdir));
		                        var i1 = new String(project.getProperty("pp_jar_fs1"));
		                        f1.setIncludes(i1);
		                        f1.setRequiredFor("preloader");
		                        var f2 = res.createFileSet();
		                        f2.setProject(project);
		                        f2.setDir(new java.io.File(pdir));
		                        var i2b = new String(project.getProperty("pp_jar_fs2"));
		                        var e2c = new String(project.getProperty("pp_jar_fs1"));
		                        f2.setIncludes(i2b);
		                        f2.setExcludes(e2c);
		                        f2.setRequiredFor("startup");
		                        var lazyjars = getLazyJars();
		                        if(lazyjars != null) {
		                            var f3 = res.createFileSet();
		                            f3.setProject(project);
		                            f3.setDir(new java.io.File(pdir));
		                            f3.setRequiredFor("runtime");
		                            setDownloadMode(f2,f3,lazyjars);
		                        }
		                    } else {
		                        var fn = res.createFileSet();
		                        fn.setProject(project);
		                        fn.setDir(new java.io.File(pdir));
		                        var ib = new String(project.getProperty("pp_jar_fs2"));
		                        fn.setIncludes(ib);
		                        fn.setRequiredFor("startup");
		                        var lazyjars = getLazyJars();
		                        if(lazyjars != null) {
		                            var fn2 = res.createFileSet();
		                            fn2.setProject(project);
		                            fn2.setDir(new java.io.File(pdir));
		                            fn2.setRequiredFor("runtime");
		                            setDownloadMode(fn,fn2,lazyjars);
		                        }
		                    }
		                    
		                    // fileset to exclude *.css or *.bss
		                    var fs = jar.createFileSet();
		                    fs.setProject(project);
		                    var buildcls = new String(project.getProperty("pp_jar_buildclasses"));
		                    var exc = new String(project.getProperty("pp_jar_cssbss"));
		                    fs.setDir(new java.io.File(buildcls));
		                    fs.setExcludes(exc);
		                    
		                    // manifest
		                    var man = jar.createManifest();
		                    var userManifestPath = project.getProperty("manifest.file");
		                    if (userManifestPath) {
		                        var userManifestFile = project.resolveFile(userManifestPath);
		                        if (userManifestFile.isFile()) {
		                            var manifestEncoding = project.getProperty("manifest.encoding");
		                            var userManifestReader = manifestEncoding ?
		                                    new java.io.InputStreamReader(
		                                        new java.io.FileInputStream(userManifestFile),
		                                        manifestEncoding) :
		                                    new java.io.InputStreamReader(
		                                        new java.io.FileInputStream(userManifestFile));
		                            try {
		                                var userManifest = new org.apache.tools.ant.taskdefs.Manifest(userManifestReader);
		                                man.merge(userManifest);
		                            } finally {
		                                userManifestReader.close();
		                            }
		                        }
		                    }
		                    var a1val = new String(project.getProperty("application.vendor"));
		                    var a1 = new org.apache.tools.ant.taskdefs.Manifest.Attribute();
		                    a1.setName("Implementation-Vendor");
		                    a1.setValue(a1val);
		                    man.addConfiguredAttribute(a1);
		                    var a2val = new String(project.getProperty("application.title"));
		                    var a2 = new org.apache.tools.ant.taskdefs.Manifest.Attribute();
		                    a2.setName("Implementation-Title");
		                    a2.setValue(a2val);
		                    man.addConfiguredAttribute(a2);
		                    if(defined(appversion)) {
		                        var a3 = new org.apache.tools.ant.taskdefs.Manifest.Attribute();
		                        a3.setName("Implementation-Version");
		                        a3.setValue(appversion);
		                        man.addConfiguredAttribute(a3);
		                    }
		                    var a4prop = new String(project.getProperty("javafx.deploy.disable.proxy"));
		                    if(isTrue(a4prop)) {
		                        var a4 = new org.apache.tools.ant.taskdefs.Manifest.Attribute();
		                        a4.setName("JavaFX-Feature-Proxy");
		                        a4.setValue("None");
		                        man.addConfiguredAttribute(a4);
		                    }
		                    // custom manifest entries
		                    var searchManifestHides = project.getProperties().keys();
		                    var manifestHides = new Array();
		                    while(searchManifestHides.hasMoreElements()) {
		                        // collect all hidden property names
		                        var pns = new String(searchManifestHides.nextElement());
		                        if(startsWith(pns, JFXMAN) && endsWith(pns, JFXPARN)) {
		                            var propns = new String(project.getProperty(pns));
		                            var phs = replaceSuffix(pns, JFXPARN, JFXPARH);
		                            var proph = new String(project.getProperty(phs));
		                            if(isTrue(proph)) {
		                                manifestHides.push(propns);
		                            }
		                         }
		                    }
		                    var manifestKeys = project.getProperties().keys();
		                    while(manifestKeys.hasMoreElements()) {
		                        var pn = new String(manifestKeys.nextElement());
		                        if(startsWith(pn, JFXMAN) && endsWith(pn, JFXPARN)) {
		                            var propn = new String(project.getProperty(pn));
		                            if(defined(propn) && !contains(manifestHides, propn)) {
		                                var propnr = propn.replace(/\s/g, "-");
		                                var entry = new org.apache.tools.ant.taskdefs.Manifest.Attribute();
		                                entry.setName(propnr);
		                                var pv = replaceSuffix(pn, JFXPARN, JFXPARV);
		                                var propv = new String(project.getProperty(pv));
		                                if(defined(propv)) {
		                                    entry.setValue(propv);
		                                } else {
		                                    entry.setValue("");
		                                }
		                                man.addConfiguredAttribute(entry);
		                            }
		                        }
		                    }
		
		'''
	}
	
	def projectProp() {
		'''
		annotation.processing.enabled=true
		annotation.processing.enabled.in.editor=false
		annotation.processing.processor.options=
		annotation.processing.processors.list=
		annotation.processing.run.all.processors=true
		annotation.processing.source.output=${build.generated.sources.dir}/ap-source-output
		application.title=src-gen
		application.vendor=ditlev
		build.classes.dir=${build.dir}/classes
		build.classes.excludes=**/*.java,**/*.form
		# This directory is removed when the project is cleaned:
		build.dir=build
		build.generated.dir=${build.dir}/generated
		build.generated.sources.dir=${build.dir}/generated-sources
		# Only compile against the classpath explicitly listed here:
		build.sysclasspath=ignore
		build.test.classes.dir=${build.dir}/test/classes
		build.test.results.dir=${build.dir}/test/results
		compile.on.save=true
		compile.on.save.unsupported.javafx=true
		# Uncomment to specify the preferred debugger connection transport:
		#debug.transport=dt_socket
		debug.classpath=\
		    ${run.classpath}
		debug.test.classpath=\
		    ${run.test.classpath}
		# This directory is removed when the project is cleaned:
		dist.dir=dist
		dist.jar=${dist.dir}/src-gen.jar
		dist.javadoc.dir=${dist.dir}/javadoc
		endorsed.classpath=
		excludes=
		includes=**
		# Non-JavaFX jar file creation is deactivated in JavaFX 2.0+ projects
		jar.archive.disabled=true
		jar.compress=false
		javac.classpath=\
		    ${javafx.classpath.extension}
		# Space-separated list of extra javac options
		javac.compilerargs=
		javac.deprecation=false
		javac.processorpath=\
		    ${javac.classpath}
		javac.source=1.8
		javac.target=1.8
		javac.test.classpath=\
		    ${javac.classpath}:\
		    ${build.classes.dir}
		javac.test.processorpath=\
		    ${javac.test.classpath}
		javadoc.additionalparam=
		javadoc.author=false
		javadoc.encoding=${source.encoding}
		javadoc.noindex=false
		javadoc.nonavbar=false
		javadoc.notree=false
		javadoc.private=false
		javadoc.splitindex=true
		javadoc.use=true
		javadoc.version=false
		javadoc.windowtitle=
		javafx.application.implementation.version=1.0
		javafx.binarycss=false
		javafx.classpath.extension=\
		    ${java.home}/lib/javaws.jar:\
		    ${java.home}/lib/deploy.jar:\
		    ${java.home}/lib/plugin.jar
		javafx.deploy.allowoffline=true
		# If true, application update mode is set to 'background', if false, update mode is set to 'eager'
		javafx.deploy.backgroundupdate=false
		javafx.deploy.embedJNLP=true
		javafx.deploy.includeDT=true
		# Set true to prevent creation of temporary copy of deployment artifacts before each run (disables concurrent runs)
		javafx.disable.concurrent.runs=false
		# Set true to enable multiple concurrent runs of the same WebStart or Run-in-Browser project
		javafx.enable.concurrent.external.runs=false
		# This is a JavaFX project
		javafx.enabled=true
		javafx.fallback.class=com.javafx.main.NoJavaFXFallback
		# Main class for JavaFX
		javafx.main.class=robotdefinitionsample.RobotDefinitionSample
		javafx.preloader.class=
		# This project does not use Preloader
		javafx.preloader.enabled=false
		javafx.preloader.jar.filename=
		javafx.preloader.jar.path=
		javafx.preloader.project.path=
		javafx.preloader.type=none
		# Set true for GlassFish only. Rebases manifest classpaths of JARs in lib dir. Not usable with signed JARs.
		javafx.rebase.libs=false
		javafx.run.height=600
		javafx.run.width=800
		# Pre-JavaFX 2.0 WebStart is deactivated in JavaFX 2.0+ projects
		jnlp.enabled=false
		# Main class for Java launcher
		main.class=com.javafx.main.Main
		# For improved security specify narrower Codebase manifest attribute to prevent RIAs from being repurposed
		manifest.custom.codebase=*
		# Specify Permissions manifest attribute to override default (choices: sandbox, all-permissions)
		manifest.custom.permissions=
		manifest.file=manifest.mf
		meta.inf.dir=${src.dir}/META-INF
		platform.active=default_platform
		run.classpath=\
		    ${dist.jar}:\
		    ${javac.classpath}:\
		    ${build.classes.dir}
		run.test.classpath=\
		    ${javac.test.classpath}:\
		    ${build.test.classes.dir}
		source.encoding=UTF-8
		src.dir=src
		test.src.dir=test
		'''
	}
	
	def project() {
		'''
		<?xml version="1.0" encoding="UTF-8"?>
		<project xmlns="http://www.netbeans.org/ns/project/1">
		    <type>org.netbeans.modules.java.j2seproject</type>
		    <configuration>
		        <buildExtensions xmlns="http://www.netbeans.org/ns/ant-build-extender/1">
		            <extension file="jfx-impl.xml" id="jfx3">
		                <dependency dependsOn="-jfx-copylibs" target="-post-jar"/>
		                <dependency dependsOn="-rebase-libs" target="-post-jar"/>
		                <dependency dependsOn="jfx-deployment" target="-post-jar"/>
		                <dependency dependsOn="jar" target="debug"/>
		                <dependency dependsOn="jar" target="profile"/>
		                <dependency dependsOn="jar" target="run"/>
		            </extension>
		        </buildExtensions>
		        <data xmlns="http://www.netbeans.org/ns/j2se-project/3">
		            <name>RobotDefinitionSample</name>
		            <source-roots>
		                <root id="src.dir"/>
		            </source-roots>
		            <test-roots>
		                <root id="test.src.dir"/>
		            </test-roots>
		        </data>
		    </configuration>
		</project>
		'''
	}
	
	
	def gitignore() {
		'''
		# Created by https://www.gitignore.io/api/netbeans
		
		### NetBeans ###
		nbproject/private/
		build/
		nbbuild/
		dist/
		nbdist/
		.nb-gradle/
		nbactions.xml
		
		
		# End of https://www.gitignore.io/api/netbeans
		'''
	}
	
	def manifest() {
		'''
		Manifest-Version: 1.0
		X-COMMENT: Main-Class will be added automatically by build
		'''
	}
	
	def build() {
		'''
		<?xml version="1.0" encoding="UTF-8"?><!-- You may freely edit this file. See commented blocks below for --><!-- some examples of how to customize the build. --><!-- (If you delete it and reopen the project it will be recreated.) --><!-- By default, only the Clean and Build commands use this build script. --><project name="RobotDefinitionSample" default="default" basedir="." xmlns:fx="javafx:com.sun.javafx.tools.ant">
		    <description>Builds, tests, and runs the project RobotDefinitionSample.</description>
		    <import file="nbproject/build-impl.xml"/>
		    <!--
		     
		     There exist several targets which are by default empty and which can be
		     used for execution of your tasks. These targets are usually executed
		     before and after some main targets. Those of them relevant for JavaFX project are:
		     
		     -pre-init:                 called before initialization of project properties
		     -post-init:                called after initialization of project properties
		     -pre-compile:              called before javac compilation
		     -post-compile:             called after javac compilation
		     -pre-compile-test:         called before javac compilation of JUnit tests
		     -post-compile-test:        called after javac compilation of JUnit tests
		     -pre-jfx-jar:              called before FX SDK specific <fx:jar> task
		     -post-jfx-jar:             called after FX SDK specific <fx:jar> task
		     -pre-jfx-deploy:           called before FX SDK specific <fx:deploy> task
		     -post-jfx-deploy:          called after FX SDK specific <fx:deploy> task
		     -pre-jfx-native:           called just after -pre-jfx-deploy if <fx:deploy> runs in native packaging mode
		     -post-jfx-native:          called just after -post-jfx-deploy if <fx:deploy> runs in native packaging mode
		     -post-clean:               called after cleaning build products
		     
		     (Targets beginning with '-' are not intended to be called on their own.)
		     
		     Example of inserting a HTML postprocessor after javaFX SDK deployment:
		     
		     <target name="-post-jfx-deploy">
		     <basename property="jfx.deployment.base" file="${jfx.deployment.jar}" suffix=".jar"/>
		     <property name="jfx.deployment.html" location="${jfx.deployment.dir}${file.separator}${jfx.deployment.base}.html"/>
		     <custompostprocess>
		     <fileset dir="${jfx.deployment.html}"/>
		     </custompostprocess>
		     </target>
		     
		     Example of calling an Ant task from JavaFX SDK. Note that access to JavaFX SDK Ant tasks must be
		     initialized; to ensure this is done add the dependence on -check-jfx-sdk-version target:
		     
		     <target name="-post-jfx-jar" depends="-check-jfx-sdk-version">
		     <echo message="Calling jar task from JavaFX SDK"/>
		     <fx:jar ...>
		     ...
		     </fx:jar>
		     </target>
		     
		     For more details about JavaFX SDK Ant tasks go to
		     http://docs.oracle.com/javafx/2/deployment/jfxpub-deployment.htm
		     
		     For list of available properties check the files
		     nbproject/build-impl.xml and nbproject/jfx-impl.xml.
		     
		     -->
		</project>
		'''
		
	}
	
	
}