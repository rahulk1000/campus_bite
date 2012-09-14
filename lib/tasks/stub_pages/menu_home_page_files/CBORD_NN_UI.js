/* =============================================================================================================
 * FileName:     CBORD_NN.js
 * Created On:   01/01/2011
 * $Revision: #2 $
 * $DateTime: 2011/05/09 15:46:53 $
 * =============================================================================================================
 */
 
 // display a panel w/ new contents and erase the other panels
 function erasePanels(toErase)
 {
    if (toErase)
    {
        for (var i = 0; i< toErase.length; i++)
        {
           erasePanel(toErase[i]);
        }
    }
 }

 // erase a panel 
 function erasePanel(id)
 {
    $('#'+id).html('');
 }

// handle the re-rendering of a div's contents and general error conditions for any post call
// id is the id of the div or null if nothing to be rendered (e.g. portion change)
// note: can get an entire page for data, which means we've had a session timeout or error: time to start over.
function postCb(id, data)
{
    var htmlPos = data.indexOf("<html");
    if (htmlPos == -1)
    {
        // no 'html' tag, so render the div (if we have one)
        if (id)
        {
            $('#' + id).html(data);
        }
    }
    else
    {
        // this should "refresh" the page
        window.location = window.location;
    }
}

// NetNutrition navigation and client-side functions
// enabling/disabling buttons based on checks
var MENU_PORTION_PREFIX = 'pcm';
var MENU_CHECKBOX_PREFIX = 'cbm';

// enable/disable buttons based on whether elements are selected (checkboxed)
function menuDetailGridCb(cbElem, oid)
{
    var disabledVal = (cbElem.checked) ? '' : 'disabled';

    // enable/disable portion SSLB based on current check box state
    $('#' + MENU_PORTION_PREFIX + oid + ':first').attr('disabled', disabledVal);

    // enable/disable Nutrition label, add to my meals, and other buttons based on collective checkbox state
    var checkedItems = (($('input[id^= "' + MENU_CHECKBOX_PREFIX + '"]:checked').length) > 0);
    disabledVal = (checkedItems) ? '' : 'disabled';
    $('#detail1:first').attr('disabled', disabledVal);
    $('#detail2:first').attr('disabled', disabledVal);
    $('#add1:first').attr('disabled', disabledVal);
    $('#add2:first').attr('disabled', disabledVal);

    // send new state of this checkbox back to session state
    $.post('Menu.aspx/SelectItem', { detailOid: oid }, function (data) { postCb(null, data); });
}

// onchange event from a portion SSLB: send oid and new amount
function portionChange(selectElem, oid)
{
    var amt = selectElem.options[selectElem.selectedIndex].value
    $.post('Menu.aspx/ChangePortion', { detailOid: oid, amount: amt }, function (data) { postCb(null, data); });
}

// onchange event from a uofm SSLB: send oid and new uofm
function setSelectedUofM(selectElem, oid)
{
    var uofmOid = selectElem.options[selectElem.selectedIndex].value
    $.post('Menu.aspx/ChangeUofM', { detailOid: oid, uofmOid: uofmOid }, function (data) { postCb(null, data); });
}

// Add the selected item(s) to "my meal"
function addToMyMeals()
{
    var form = Get_NN_Form()
    $.post('MyMeals.aspx/AddToMyMeal', form.serialize(), function (data) { postCb('myMeal', data); });
}

// Render the labels for the item on mouseover
function getMyMealNutritionLabel(oid, unitOid, uofmOid) 
{
    var topPos = getScrollPos();
    $('#nutritionLabelPanel').css({ "top": topPos });
    $.post('NutritionDetail.aspx/ShowMyMealNutritionLabel', { detailOid: oid, unitOid: unitOid, uofmOid: uofmOid }, function (data) { $('#nutritionLabelPanel').html(data); });    
}

// Render the labels for the item on mouseover
function getItemNutritionLabel(oid) 
{
    var topPos = getScrollPos();
    $('#nutritionLabelPanel').css({ "top": topPos });
    $.post('NutritionDetail.aspx/ShowItemNutritionLabel', { detailOid: oid }, function (data) { postCb('nutritionLabelPanel', data); });
}

// Render the nutrition grid for the selected items in the current menu
function getItemNutritionGrid()
{
    closeNutritionDetailPanel();
    var topPos = getScrollPos();
    $('#nutritionGridPanel').css({ "top": topPos });
    $.post('NutritionDetail.aspx/ShowMenuDetailNutritionGrid', null, function (data) { postCb('nutritionGridPanel', data); });
}

// render the nutrtion grid for the items in my meal
function getMyMealSummaryNutrition()
{
    closeNutritionDetailPanel(); 
    var topPos = getScrollPos();
    $('#nutritionGridPanel').css({ "top": topPos });
    $.post('NutritionDetail.aspx/ShowMyMealSummaryNutritionGrid', null, function (data) { postCb('nutritionGridPanel', data); });
}

// close the nutritiongrid
function closeNutritionGrid()
{
    erasePanel('nutritionGrid');
    $.post('NutritionDetail.aspx/CloseItemNutritionGrid', null, function (data) { postCb('nutritionGridPanel', data); });
}

// clse the nutrition label
function closeNutritionDetailPanel() 
{
    erasePanel('nutritionLabel');
}

// remove the given detail from my meal
function myMealRemove(oid, unitOid, uofmOid)
{
    $.post('MyMeals.aspx/RemoveItem', { detailOid: oid, unitOid: unitOid, uofmOid: uofmOid }, function (data) { postCb('myMeal', data); });
}

// change the portion for an item in my meal.
function myMealPortionChange(selectElem, unitOid, oid, uofmOid)
{
    var amt = selectElem.options[selectElem.selectedIndex].value
    $.post('MyMeals.aspx/ChangePortion', { unitOid: unitOid, detailOid: oid, uofmOid: uofmOid, amount: amt }, function (data) { postCb(null, data); });
}

// clear the contents of "my meal"
function clearMyMeals() 
{
    $.post('MyMeals.aspx/ClearMyMeal', null, function (data) { postCb('myMeal', data); });
}

// show myMeals in mobile app
function showMyMeals(toErase)
{
    erasePanels(toErase)
    $.post('MyMeals.aspx/MyMealList', null, function (data) { postCb('myMeal', data); });
}

// callback for a trait checkbox
function traitListCb(cbElem, oid)
{
    // toggle this checkbox back in session state
    var menuOpen = false;
    // if the item panel exists and is not empty refresh it
    if ($('#itemPanel').length > 0) 
    {
        if ($('#itemPanel').html().length != 0)
        {
            menuOpen = true;
        }
    }
    $.post('Menu.aspx/SelectTrait', { detailOid: oid, menuOpen: menuOpen }, function (data) { postCb('itemPanel', data); });
}

// clear all filters so that all menu items will be shown
function clearFilters()
{
    $('input[id^=allergy]').attr('checked', false);
    $('input[id^=pref]').attr('checked', false);

    var menuOpen = false;
    // if the item panel exists and is not empty refresh it
    if ($('#itemPanel').length > 0) 
    {
        if ($('#itemPanel').html().length != 0)
        {
            menuOpen = true;
        }
    }
    $.post('Menu.aspx/ClearFilters', { menuOpen: menuOpen }, function (data) { postCb('itemPanel', data); });
}

// open the details for the given menu with the applied filters. 
function openMenu(unitOid, menuOid, toErase) 
{
    erasePanels(toErase);
    $.post('Menu.aspx/OpenMenu', {unitOid: unitOid, menuOid: menuOid }, function (data) { postCb('itemPanel', data); });
}

// open the set of courses associated with this menu
function openCourse(unitOid, menuOid, toErase)
{
    erasePanels(toErase);
    $.post('Menu.aspx/OpenCourses', {unitOid: unitOid, menuOid: menuOid }, function (data) { postCb('coursesPanel', data); });
}

// handle a course selection: render the corresponding menu details
function selectCourse(courseOid, toErase)
{
    erasePanels(toErase);
    $.post('Menu.aspx/SelectCourse', { oid: courseOid }, function (data) { postCb('itemPanel', data); });
}

// show the menus for the selected unit (NN unit oid)
function getUnitMenus(unitID, toErase)
{
    erasePanels(toErase);
    $.post('Menu.aspx/SetMenuUnit', {unitOid: unitID }, function (data) { postCb('menuPanel', data); });
}

// show subunits of a selected parent unit
function getUnits(unitID, toErase)
{
    erasePanels(toErase);
    $.post('Unit.aspx/SetUnitList', { oidParm: unitID }, function (data) { postCb('unitsPanel', data); });
}

// show subunits of a geinv parent unit
function getChildUnits(unitID, toErase)
{
    erasePanels(toErase);
    $.post('Unit.aspx/SelectUnitChildren', { oid: unitID }, function (data) { postCb('childUnitsPanel', data); });
}

// handle a goal radio button click
function selectGoal(radioBtn)
{
    $.post('NutritionGoals.aspx/SelectGoal', { oid: radioBtn.value }, function (data) { postCb(null, data); });
}

// handle a goal radio button click
function openStaticPanel(panelID, toErase)
{
    erasePanels(toErase);
    $.post('Home.aspx/OpenStaticPanel', { PanelID: panelID }, function (data) { postCb(panelID, data); });
}

// Close error panel
function closeErrorPanel()
{
    erasePanel('errorPanel');
}

// if a rendering error occurs, refresh session and start over.
function repositionAfterError(extID)
{
    $.post('Home.aspx/StartOver', null, function (data) { });
    window.location = "./home.aspx?NNexternalID="+extID;
}

// return the main form. 
function Get_NN_Form() 
{
    var formToUse = $('#cbo_nn_Form');
    return formToUse;
}

// return the current scroll position (for as many browsers as possible)
function getScrollPos()
{
    var ScrollTop = document.body.scrollTop;
    if (ScrollTop == null || ScrollTop == 0)
    {
        if (window.pageYOffset)
            ScrollTop = window.pageYOffset;
        else
            ScrollTop = (document.body.parentElement) ? document.body.parentElement.scrollTop : 0;
    }
    // If we can't find the scroll position set it to 0 
    if (ScrollTop == null)
    {
        return 0;
    }
    return ScrollTop;
}

// Unit Tree functions
this.UnitTreeList = function ()
{
    // edit 

    var expandTo = 1; // level up to which you want your lists to be initially expanded. 1 is minimum
    var expandText = "Expand All"; // text for expand all button
    var collapseText = "Collapse All"; // text for collapse all button		
    var listClass = "cbo_nn_unitTreeListDiv" // Name of class to associate with these functions

    // end edit (do not edit below this line)

    this.start = function ()
    {
        var ul = document.getElementsByTagName("ul");
        // find a ul that matches the desire class 'listClass'
        for (var i = 0; i < ul.length; i++)
        {
            if (ul[i].className == listClass)
            {
                // create the 
                create(ul[i]);
                // add button to expand/collapse all
                buttons(ul[i]);
            }
        }
    };

    // Build the list if ul/li elements
    this.create = function (list)
    {
        var items = list.getElementsByTagName("li");
        for (var i = 0; i < items.length; i++)
        {
            listItem(items[i]);
        }
    };

    // render ul/li elements 
    this.listItem = function (li)
    {
        if (li.getElementsByTagName("ul").length > 0)
        {
            var ul = li.getElementsByTagName("ul")[0];
            // if li position is lower than original depth hide it
            ul.style.display = (depth(ul) <= expandTo) ? "block" : "none";
            li.className = (depth(ul) <= expandTo) ? "expanded" : "collapsed";
            // used to determine which element is being expanded/collapse
            li.over = true;
            // add handlers to set element over
            ul.onmouseover = function () { li.over = false; }
            ul.onmouseout = function () { li.over = true; }
            li.onclick = function ()
            {
                if (this.over)
                {
                    ul.style.display = (ul.style.display == "none") ? "block" : "none";
                    this.className = (ul.style.display == "none") ? "collapsed" : "expanded";
                }
            }
        }
    };

    // build buttons as links
    // parm list - entire list of elements
    this.buttons = function (list)
    {
        var parent = list.parentNode;
        var p = document.createElement("p");
        p.className = listClass;
        // add expand button
        var a = document.createElement("a");
        a.innerHTML = expandText;
        a.onclick = function () { expand(list) };
        p.appendChild(a);
        //add collapseText buttoin
        var a = document.createElement("a");
        a.innerHTML = collapseText;
        a.onclick = function () { collapse(list) };
        p.appendChild(a);
        parent.insertBefore(p, list);
    };

    // expand (make visible) elements in the list passed
    this.expand = function (list)
    {
        li = list.getElementsByTagName("li");
        for (var i = 0; i < li.length; i++)
        {
            if (li[i].getElementsByTagName("ul").length > 0)
            {
                var ul = li[i].getElementsByTagName("ul")[0];
                ul.style.display = "block";
                li[i].className = "expanded";
            }
        }
    };

    // collapse (hide) elements in the list passed
    this.collapse = function (list)
    {
        li = list.getElementsByTagName("li");
        for (var i = 0; i < li.length; i++)
        {
            if (li[i].getElementsByTagName("ul").length > 0)
            {
                var ul = li[i].getElementsByTagName("ul")[0];
                ul.style.display = "none";
                li[i].className = "collapsed";
            }
        }
    };

    // determine location in list of given element (obj)
    this.depth = function (obj)
    {
        var level = 1;
        while (obj.parentNode.className != listClass)
        {
            if (obj.tagName == "UL") level++;
            obj = obj.parentNode;
        };
        return level;
    };

    // start the function
    start();
} // end tree list object
