<%--
Copyright Grupo LPA. 2011. All Rights Reserved.
version 0.1 - 18/07/2011 commentary
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.filenet.wcm.toolkit.server.util.WcmServerCredentials,
         com.filenet.wcm.toolkit.server.util.WcmDataStore" %>

<%@ page import="com.filenet.ae.util.state.WindowScope" %>
<%@ page import="com.filenet.ae.util.encoder.EncodingUtil" %>
<%@ page import="com.filenet.ae.util.FacesUtil" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://www.filenet.com/faces" prefix="fn" %>

<%!
    public String generateUserToken(WcmServerCredentials sc) throws Exception {
        com.filenet.wcm.api.Session sess = sc.getSession();
        //System.out.println("sess.getToken(): " + sess.getToken());
        return sess.getToken();
    }

    public String generateUserToken(WcmDataStore ds, WcmServerCredentials sc) throws Exception {
        String token = sc.getSessionToken(ds, sc.getAppId(), sc.getRawUserId(), sc.getPassword());
        return token;
    }

    public boolean isMemberOf(WcmServerCredentials sc, String groupName) {
        //String fullGroupName = groupName + '@' + sc.getUserRealm();
        System.out.println("Variable: " + groupName);
        //System.out.println("fullGroupName: " + fullGroupName);
        //java.util.Set groupSet = sc.getUserGroups();
        //return groupSet.contains(fullGroupName);
        com.filenet.wcm.api.User user = sc.getUserObject();
        com.filenet.wcm.api.Groups groups = user.getParentGroups();
        if (groups != null && groupName != null && groupName.length() > 0) {
            java.util.Iterator itera = groups.iterator();
            com.filenet.wcm.api.Group group;
            String tmp;
            System.out.println("fullGroupName: 1");
            while (itera.hasNext()) {
                group = (com.filenet.wcm.api.Group) itera.next();
                System.out.println("group.getName(): " + group.getName());
                if (group != null && group.getName() != null) {
                    tmp = group.getName().toLowerCase();
                    System.out.println("fullGroupName: 2");
                    //System.out.println("fullGroupName: ---imp "+ tmp);
                    //tmp =  "cn=" + groupName.toLowerCase() + "," ;
                    System.out.println("NUEVO TEMP // " + tmp);
                    //System.out.println("GroupName: ---"+ groupName.toLowerCase());

                    //if (tmp.startsWith("cn=" + groupName.toLowerCase() + ",")) {
                    if (tmp.startsWith(groupName.toLowerCase())) {
                        System.out.println("fullGroupName: 3");

                        return true;
                        /*if (tmp.indexOf(sc.getUserRealm().getName().toLowerCase()) != -1) {
                                                 System.out.println("fullGroupName: 4");
                       return true;
                    }*/
                    }
                }
            }
        }
        return false;
    }

    public void listMethods(Class clazz) {

        //Get the methods
        java.lang.reflect.Method[] methods = clazz.getMethods(); //getDeclaredMethods

        System.out.println("---- Methods of: " + clazz);
        //Loop through the methods and print out their names
        for (java.lang.reflect.Method method : methods) {
            System.out.println(method.getName() + " > " + method.getReturnType());
        }
    }
%>
<%
    WcmDataStore ds = WcmDataStore.get(application, request, true);
    WcmServerCredentials sc = ds.getServerCredentials();
//listMethods(WcmServerCredentials.class);
//listMethods(com.filenet.wcm.api.Session.class);
//listMethods(com.filenet.wcm.api.Groups.class);
//listMethods(com.filenet.wcm.api.impl.RealmImpl.class);
%>
<%
    FacesUtil.getRequestMap().put(WindowScope.WINDOW_ID_KEY, WindowScope.MAIN_WINDOW);
%>

<f:view>
    <f:loadBundle basename="com.filenet.ae.application.GlobalResources" var="appResource"/>

    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Strict//EN">
    <html lang="<h:outputText value="#{localeInfo.lang}" />">
    <head>
        <title>Trámite Documentario</title>
        <link rel="stylesheet" href="css/Application.css"/>
    <link rel="stylesheet" href="css/<h:outputText value="#{localeInfo.dir}" />.css" id="css_<h:outputText value="#{localeInfo.dir}" />" />
    <%
        //noinspection RedundantArrayCreation
        EncodingUtil.includeJavaScript(out, new String[]{"Util.js", "Mail.js", "Ajax.js", "Menu.js", "List.js", "Tree.js", "DD.js", "ActionsMenu.js", "Positioning.js", "Property.js", "Search.js", "ControlSheet.js", "WaitScreen.js", "ComboBox.js", "FileTracker.js"});
        //EncodingUtil.includeJavaScript(out, new String[]{"Util.js", "Menu.js", "Positioning.js"});
    %>

    <!-- Monus: hide splitter handler and change cursor to default -->
    <style>

        /*  Modificado Req #9000003154 #splitterDiv {
               background-image: none;
               cursor: default;
            }*/
    </style>
    <link rel="stylesheet" href="/InspectorWeb/js/dtree/dtree.css"/>
    <script type="text/javascript" src="/InspectorWeb/js/dtree/dtree.js"></script>
    <script type="text/javascript">

        var WobNumTD = [];
        var rowSelected = [];
        if ((typeof WobNumTD !== 'undefined') && (typeof rowSelected !== 'undefined')) {
            for (var i = 0; i < 10; i++) {
                WobNumTD[i] = null;
                rowSelected[i] = false;
            }
        }

        function getvalueCorrelativo(index, correlativotmp) {
            correlativotmp = null;
            if ((typeof WobNumTD !== 'undefined') && (typeof rowSelected !== 'undefined'))
                correlativotmp = WobNumTD[index];
        }

        function getvalueSelectedCorresp(index) {
            var correspondenciaselected = false;
            if ((typeof WobNumTD !== 'undefined') && (typeof rowSelected !== 'undefined'))
                correspondenciaselected = rowSelected[index];
            return correspondenciaselected;
        }

        //FnActions.nodePath = "";
        //FnActions.folderSelected = false;



        //Monus: function to prepare the work area
        FnWM.DEFAULT_PANE_A_WIDTH = 273;
        // Ticket 3154 #
        function resizeScreenInspector() {
            windowResize();
        }
        // <!-- FIX IE 7  -->
        //window.addEventListener("resize", resizeScreenInspector);
        // <!-- FIX IE 7  -->
        // -- Ticket 3154 #
        /*	function prepareWorkArea() {
         Ext.getBody().on("resize", windowResize);
         if (FnWM.splitter) {
         //FnWM.splitter.offsetLeft = FnWM.DEFAULT_PANE_A_WIDTH;
         //FnWM.saveVerticalSplitterPosition();
         //FnWM.recallVerticalSplitterPosition();
         //FnWM.initWindow(window);
         //FnWM.cookie.remove("browseVerticalSplitterPosition");
         //FnUtil.LTR = true;
         //FnWM.fitWindow(false);
         FnWM.splitter.onmousedown = null;
         }
         if (FnWM.rightTopSplitter) {
         FnWM.rightTopSplitter.onmousedown = null;
         FnWM.rightTopSplitter.ondblclick = null;
         }
         }*/
    </script>

    <!-- @ include file="include/InitializeContextMenu.jsp" -->
    <%@ include file="include/LoadJSResources.jsp" %>
    <!-- Begin include/InspectorInclude.jsp -->
    <% String workplaceContext = "/WorkplaceXT";
        String inspectorContext = "/InspectorWeb";
        request.setAttribute("InspectorModule", "Hello");%>
    <link rel="stylesheet" type="text/css" href="<%=inspectorContext%>/css/wfm.css" />
    <link rel="stylesheet" type="text/css" href="<%=inspectorContext%>/css/icons.css" />
    <link rel="stylesheet" type="text/css" href="<%=inspectorContext%>/css/navigator.css" />
    <link rel="stylesheet" type="text/css" href='<%=inspectorContext%>/ext-2.2/resources/css/ext-all.css'/>
    <link rel="stylesheet" type="text/css" href="<%=inspectorContext%>/css/Spinner.css" />
    <link rel="stylesheet" type="text/css" href="<%=inspectorContext%>/css/ExtJSAdds.css" />
    <script type="text/javascript" src='<%=inspectorContext%>/ext-2.2/adapter/ext/ext-base.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/ext-2.2/ext-all-debug.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/ext-2.2/locale/ext-lang-es.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/ExtFix.js'></script>
    <script type="text/javascript" src='<%=workplaceContext%>/js/MultiSelect.js' charset="utf-8"></script>
    <!-- FIX IE 7  -->
    <script type="text/javascript" src='<%=workplaceContext%>/js/iecheck.js' charset='utf-8'></script>
    <script type="text/javascript">
        if (IeVersion().IsIE)
        {
            var IEVer = parseInt(IeVersion().ActingVersion);
            if (IEVer <= 8)
            {
                //document.write("<script type=\"text/javascript\" src='<%=workplaceContext%>/js/addEventListener.js'><\/script>");
                document.write("<script type=\"text/javascript\" src='<%=workplaceContext%>/js/getElementsByClassName.js'><\/script>");
            }
        }

    </script>
    <script type="text/javascript" src='<%=workplaceContext%>/js/Functions.js'></script>
    <!-- FIX IE 7  -->
    <script type="text/javascript">
        var WORKPLACE_CONTEXT = '<%=workplaceContext%>';
        var INSPECTOR_CONTEXT = '<%=inspectorContext%>';
        Ext.BLANK_IMAGE_URL = '<%=inspectorContext%>/images/s.gif';
        var loggedIn = false;
        Ext.onReady(function () {
            //Ext.get('wfm-cont').parent("td[valign='top']").addClass('backLogo');
            Ext.get(wxtContainerId).addClass('backLogo');
            Ext.Ajax.request({
                url: INSPECTOR_CONTEXT + '/wfm/workplace/init.action',
                success: function (res, opts) {
                    loggedIn = true;
        <% if (request.getParameter("ctx") != null) {%>
                    showCtx('<%=request.getParameter("ctx")%>');
        <% }%>
                }/*,
                 failure: function (res, opts) {
                 window.alert('Error al contactar a InspectorWeb.\n' + res.responseText);
                 }*/
                , params: {
                    userToken: '<%=generateUserToken(sc)%>'
                }
            });


//

            var usuario = '<%=sc.getRawUserId()%>';
            var verificarPermisosMenu = true;

            //	Ext.Ajax.request({
            //		url: '/TramiteDocumentario/json/GenericosCartero/verificarPermisosMenu',
            //		method: 'POST',
            //		success: function(res) {
            //			if(res.responseText=="true"){
            //				verificarPermisosMenu=true;
            //				document.getElementById("dmenu0").style.visibility="visible";
            //				document.getElementById("imenu0").style.visibility="visible";
            //			}else{
            //				verificarPermisosMenu=true;
            //				deleteMenu();
            //			}
            //		},
            //		failure: function(res) {
            //			verificarPermisosMenu=false;
            //			deleteMenu();
            //		},
            //		params: {
            //			'aplicacion': 'TramiteDocumentario',
            //			'usuario': usuario
            //		}
            //	});
//				



            function keepAliveWorkplace() {
                Ext.Ajax.request({
                    url: WORKPLACE_CONTEXT + '/Browse.jsf'
                });
            }
            window.setInterval(keepAliveWorkplace, 180000);
            function keepAliveInspector() {
                Ext.Ajax.request({
                    url: INSPECTOR_CONTEXT + '/wfm/workplace/heartBeat.action'
                });
            }
            window.setInterval(keepAliveInspector, 200000);
            function getParameterByName(name, url) {
                if (!url)
                    url = window.location.href;
                name = name.replace(/[\[\]]/g, '\\$&');
                var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
                        results = regex.exec(url);
                if (!results)
                    return null;
                if (!results[2])
                    return '';
                return decodeURIComponent(results[2].replace(/\+/g, ' '));
            }

            function getDataSource(name, response) {
                for (var i = 0; i < response.length; i++)
                {
                    datasource = response[i];

                    if (datasource.name == name)
                    {
                        return datasource;
                    }

                }
            }


            function openTaskWindow() {


                var currentURL = window.location.href;

                if (currentURL.indexOf('?') != -1) {

                    var wobNum = getParameterByName("wobNum", currentURL);
                    var queueName = getParameterByName("queueName", currentURL);

                    if (wobNum != undefined | wobNum != null && queueName != undefined | queueName != null) {

                        Ext.Ajax.request({

                            url: INSPECTOR_CONTEXT + '/wfm/' + 'BandejasTD' + '/getDataSources.action',
                            success: function (res, opts) {

                                var params = {};
                                params.wobNum = wobNum;
                                params.queueName = queueName;
                                
                                console.log("MSIE API de consola disponible.");

                                var response = Ext.decode(res.responseText);
                                var datasource = getDataSource(params.queueName, response);

                                if (datasource != null) {
                                    params.buttonId = datasource.queries[0].buttons[0].idButton;
                                    params.queryConfig = Ext.decode(datasource.queries[0].config);
                                    showContext("BandejasTD", params);

                                }
                            },

                            failure: function (res, opts) {
                                showError(res);
                            },
                            params: {}

                        });

                      //  if (IeVersion().IsIE) {

                       //     var IEVer = parseInt(IeVersion().ActingVersion);
                       //     if (IEVer >= 8) {
                       //         window.history.replaceState(null, null, window.location.pathname);
                       //     }
                     //   } else {

                            window.history.replaceState(null, null, window.location.pathname);
                            
                     //   }


                    }
                }

            }

            setTimeout(function () {
                openTaskWindow();
            }, 2000);

        });

        function signOut() {
            //window.alert('Inspector Sign Out');
            Ext.Ajax.request({
                url: INSPECTOR_CONTEXT + '/wfm/workplace/signOff.action',
                success: function () {
                    window.location.href = '/Workplace/Browse.jsp?eventTarget=WcmController&eventName=SignOut';
                }/*,
                 failure: function () {
                 window.alert('Error al salir del Inspector.');
                 }*/
            });
            /*Ext.Ajax.request({
             url: '/Workplace/Browse.jsp?eventTarget=WcmController&eventName=SignOut',
             //failure: function () {
             //	window.alert('Error al salir del Workplace.');
             //},
             success: function () {
             window.location.href = 'LPAModule.jsp?eventTarget=WcmController&eventName=SignOut';
             }
             });*/
            return false;
        }
        /*Ext.onReady(function() {
         var links = Ext.select("table[class='bannerTable'] td");
         if (links && links.getCount() == 3) {
         //links.item(2).dom.innerHTML = '<a href="#" onclick="return signOut();">Registrar Salida</a>';
         //Ext.select("table[class='bannerTable'] td").item(2).dom.children.item(3).innerHTML = '<a href="#" onclick="return signOut();">Registrar Salida</a>';
         var link = links.item(2).dom.children.item(3);
         link.href = "#";
         link.onclick = function () { return signOut(); };
         //link.innerHTML = '<a href="#" onclick="return signOut();">' + link.innerHTML + '</a>';
         //link.innerHTML = '<a href="#" onclick="return signOut();">Salir</a>';
         }
         });*/
    </script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/Commons.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/miframe.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/DockablePanel.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/Spinner.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/SpinnerStrategy.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/ThemeMenu.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/ProgressPagingToolbar.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/inspector/ExtStepProcessor.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/inspector/eFormProcessor.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/inspector/DataBaseEditor.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/inspector/Inspector.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/inspector/DBInspector.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/inspector/PEInspector.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/WorkflowManagerXT.js'></script>

    <script type="text/javascript" src='<%=inspectorContext%>/js/navigator/Navigator-Commons.js'></script>

    <script type="text/javascript" src='<%=inspectorContext%>/js/navigator/Navigator-Texts-es.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/navigator/Navigator-Types.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/navigator/Navigator-Panel.js'></script>
    <!--script type="text/javascript" src='<%=inspectorContext%>/js/navigator/Navigator-Window.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/navigator/Navigator-Main.js'></script-->

    <script type="text/javascript" src='<%=inspectorContext%>/js/components/RowExpander.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/PagingMemoryProxy.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/components/ProgressBarPager.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/grids/Grids-Commons.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/grids/Grids-GridPanel.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/grids/Grids-GridSetPanel.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/grids/Grids-Window.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/grids/Grids-Main.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/grids/Grids-Main.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/designer/LPA/DesignerFields.js'></script>
    <script type="text/javascript" src='<%=inspectorContext%>/js/inspector/ScreenProcessor.js'></script>
    <!-- End include/InspectorInclude.jsp -->


    <!-- Begin include/TramiteDocumentario JS file (Req.44) -->

    <!-- <script type="text/javascript" src="/TramiteDocumentario/js/json2.min.js"></script> -->
    <script type="text/javascript" src="/TramiteDocumentario/js/PlantillaWord.js"></script>

    <!-- End   include/TramiteDocumentario JS file (Req.44) -->


    <!-- Begin CustomPrimaryView.jsp -->

    <%@ include file="TramiteDocumentarioInclude.jsp" %>

    <!-- End CustomPrimaryView.jsp -->
</head>
<!--body onload="FnWM.initWindow(this); FnUtil.executeCallbacks(FnUtil.onLoadCallbacks); $('FORM:skipToContentLink').focus(); FnMajorAreaNavigation.attachHandler(); prepareWorkArea();"-->
<!--  Modificado Req #9000003154  <body onload="FnWM.initWindow(this); prepareWorkArea();"> -->
<body onload="FnWM.initWindow(this);">
<h:form id="FORM">
    <input type="hidden" id="wIdField" name="wIdField" value="<%=WindowScope.getWindowId()%>" />

    <h:outputLink value="javascript:void(0);" tabindex="-1" styleClass="skipToContentLink" onclick="return FnWM.focusOnFirstTreeNode();" id="skipToContentLink">
        <h:outputText value="#{appResource.skipToMainContentLink}" />
    </h:outputLink>

    <!-- Begin include/InspectorHeader.jsp -->
    <input type="hidden" id="usuarioLogin" name="usuarioLogin" value="<%=sc.getRawUserId()%>">
    <div id="headerDiv">

        <!-- Banner -->
        <div id="BANNER_DIV" tabindex="-1">
            <table id="bannerTable" cellpadding="0" cellspacing="0" border="0">
                <tr>
                    <!-- FIX IE 7  -->
                <script type="text/javascript">
                    if (IeVersion().IsIE)
                    {
                        var IEVer = parseInt(IeVersion().ActingVersion);
                        if (IEVer <= 9)
                        {
                            document.write("<td id=\"bannerLogoIE7_9\"></td>");
                        } else
                        {
                            document.write("<td id=\"bannerLogoIE10\"></td>");
                        }
                    } else
                    {
                        document.write("<td id=\"bannerLogoIE10\"></td>");
                    }

                </script>
                <!-- FIX IE 7  -->
                <td id="bannerProductText" nowrap="true">
                    <!-- Modified2 -->
                      <!-- <h:outputText value="#{appResource.application}"/> -->
                    <p style="font-size: 20px;">Sistema de Tr&#225;mite Documentario y Correspondencia - SISTCORR</p>
                </td>
                <td id="loggedInUser" width="10%" nowrap="true" valign="bottom">
                <h:outputText value="#{appResource.loggedinas} #{configuration.dataStore.serverCredentials.userDisplayName}"/>
                </td>
                </tr>
            </table>
            <!-- MOD 3154 -->
            <!-- FIX IE 7  -->
            <div class="hr"></div>
            <!-- FIX IE 7  -->
            <!-- MOD 3154 -->
            <!-- Global bar -->
            <table cellpadding="0" cellspacing="0" border="0" width="100%" id="menuBar" tabindex="-1">
                <tr>
                    <!-- td id="TOOLS_MENU_CELL" nowrap="true" width="50%">
                        <h:outputLink id="TOOLS_MENU_LINK" onclick="return FnMenu.showContextMenu(event, this, this, null, null, null, 'TOOLSMENU');" value="#">
                            <h:outputText value="#{appResource.tools}"/>
                        </h:outputLink>
                    </td -->
                    <td id="MENU_BAR_LINKS_CELL" nowrap="true" width="50%">
                <h:outputLink id="USERPREFS" onclick="return FnUtil.createWindow('WcmUserPreferences.jsp?windowIdMode=CREATE_POPUP&returnUrl=utils/PickUpUserPrefsChanges.jsf', '', 'no', 'no', 'yes', 'yes', 'yes', 960, 650, 'center', 'middle', 'yes');" value="#">
                    <h:outputText value="#{appResource.preferences}"/>
                </h:outputLink>
                |
                <h:outputLink id="HELP" onclick="#{helpManager.helpPage}" value="#">
                    <h:outputText value="#{appResource.help}"/>
                </h:outputLink>
                |
                <h:outputLink id="LOGOUT" value="ContainerSignout.jsp" >
                    <h:outputText value="#{appResource.logout}"/>
                </h:outputLink>
                </td>
                </tr>
            </table>
        </div>

        <!-- toolbar -->
        <div id="TOOLBAR_DIV" tabindex="-1">
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <table border="0" cellpadding="0" cellspacing="0" id="TOOLBAR_TABLE">
                            <tr>
                                <td class="toolbarCell viewSelectionCell">
                            <fn:view id="VIEW">
                                <h:commandLink styleClass="viewButton" id="TramiteDocumentario" action="TramiteDocumentario" actionListener="#{searchWorker.handleViewChange}" title="Trámite Documentario">
                                    <h:graphicImage alt="Trámite Documentario"  id="VIEW_TramiteDocumentario" styleClass="viewImage" value="images/TramiteDocumentario/TramiteDocumentario.gif"
                                                    onmouseover="this.src = 'images/TramiteDocumentario/TramiteDocumentarioHover.gif'"
                                                    onmouseout="this.src = 'images/TramiteDocumentario/TramiteDocumentario.gif'"/>
                                </h:commandLink>
                                <h:commandLink styleClass="viewButton" id="home" action="myworkplace" actionListener="#{searchWorker.handleViewChange}" title="#{appResource.home}">
                                    <h:graphicImage alt="#{appResource.home}" id="VIEW_home" styleClass="viewImage" value="images/web/view/ToggleMywork24.gif"
                                                    onmouseover="this.src = 'images/web/view/ToggleMyworkHover24.gif'"
                                                    onmouseout="this.src = 'images/web/view/ToggleMywork24.gif'"/>
                                </h:commandLink>
                                <h:commandLink styleClass="viewButton" id="browse" action="browse" actionListener="#{searchWorker.handleViewChange}" title="#{appResource.browse}">
                                    <h:graphicImage alt="#{appResource.browseMode}"  id="VIEW_browse" styleClass="viewImage" value="images/web/view/ToggleBrowse24.gif"
                                                    onmouseover="this.src = 'images/web/view/ToggleBrowseHover24.gif'"
                                                    onmouseout="this.src = 'images/web/view/ToggleBrowse24.gif'"/>
                                </h:commandLink>
                                <h:commandLink styleClass="viewButton" id="search" action="search" title="#{appResource.search}">
                                    <h:graphicImage alt="#{appResource.searchMode}"  id="VIEW_search" styleClass="viewImage" value="images/web/view/ToggleSearch24.gif"
                                                    onmouseover="this.src = 'images/web/view/ToggleSearchHover24.gif'"
                                                    onmouseout="this.src = 'images/web/view/ToggleSearch24.gif'"/>
                                </h:commandLink>
                                <h:commandLink styleClass="viewButton" id="tasks" action="tasks" actionListener="#{searchWorker.handleViewChange}" title="#{appResource.tasks}">
                                    <h:graphicImage alt="#{appResource.tasks}"  id="VIEW_tasks" styleClass="viewImage" value="images/web/view/ToggleTasks24.gif"
                                                    onmouseover="this.src = 'images/web/view/ToggleTasksHover24.gif'"
                                                    onmouseout="this.src = 'images/web/view/ToggleTasks24.gif'"/>
                                </h:commandLink>
                            </fn:view>
                    </td>
                    <!-- td class="toolbarCell">
                        <table id="ACTIONS_BUTTON" border="0" cellpadding="0" cellspacing="0" title="<h:outputText value='#{appResource.actionsButtonTooltip}'/>"
                               onkeypress="if (FnUtil.getKeyCode(event) == 13){return FnActions.showActionsMenu(event);}"
                               oncontextmenu="return FnActions.showActionsMenu(event);"
                               onclick="return FnActions.showActionsMenu(event);"
                               onmouseover="this.className = 'hover';"
                               onmouseout="this.className = null;">
                            <tr>
                                <td class="left"></td>
                                <td class="center" nowrap="true"><a href="#"><h:outputText value="#{appResource.actionsButton}"/></a></td>
                                <td class="right"></td>
                            </tr>
                        </table>
                    </td>
                    <td class="toolbarCell">
                        <fn:folderActionsToolbar id="ADD_TOOLBAR" />
                    </td>
                    <td class="toolbarCell">
                        <fn:contextToolbar id="TOOLBAR" toolbarActions="toolbarActions" selectionExpression="FnActions.getSelectedObject()"/>
                    </td-->
                </tr>
            </table>

            </td>
            <!-- applet cell -->
            <td id="APPLET_CELL">
                <script type="text/javascript">
                    //FnActions.addDragAndDropApplet();
                </script>
            </td>
            </tr>
            </table>
        </div>
    </div>

</h:form>
<!-- End include/InspectorHeader.jsp -->

<!-- Begin include/InspectorPageContent.jsp -->
<div id="paneA">
    <div style="padding: 9px 0px 0px 9px;">
        <script type="text/javascript">
        <!--

            document.write(menu);
        // <!-- FIX IE 7  -->
            Ext.EventManager.onWindowResize(function(w, h){
                resizeScreenInspector();
            });
        // <!-- FIX IE 7  -->
        //-->
        </script>
    </div>
</div>

<%-- Splitter --%>
<div id="splitterDiv"></div>

<%-- Content area --%>
<div id="CONTENT_REGION">
    <div id="paneB">
        <div id="wfm-cont"></div>
    </div>
</div>

<%-- status bar --%>
<div id="statusBarDiv"></div>

<%@ include file="include/Alert.jsp" %>
<%@ include file="include/WaitScreen.jsp" %>
<!-- End include/InspectorPageContent.jsp -->

<!-- @ include file="include/ToolsMenu.jsp" -->

</body>
</html>

</f:view>
