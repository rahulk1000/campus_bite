/* =============================================================================================================
 * FileName:     CBORD_NN.js
 * Created On:   01/01/2011
 * $Revision: #38 $
 * $DateTime: 2012/03/23 15:17:31 $
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
    var htmlPos = -1;
    // might not get a string from a $post, so be careful here
    if (typeof data == "string")
    {
        htmlPos = data.indexOf("<html");
    }
    else
    {
        // get out now as we returned a non-string (most likely an empty rendering)
        return;
    }

    // if NOT the whole page, render the panel if given
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
    // enable/disable Nutrition label, add to my meals, and other buttons based on collective checkbox state
    var checkedItems = (($('input[id^= "' + MENU_CHECKBOX_PREFIX + '"]:checked').length) > 0);
    var disabledVal = !(checkedItems);
    setMenuItemButtonsDisabledState(disabledVal);

    // send new state of this checkbox back to session state (render any errors w/ null id)
    $.post('Menu.aspx/SelectItem', { detailOid: oid }, function (data) { postCb(null, data); });
}

// set the enabled status of the Nutrition Label and 'add to my meals' buttons
// 'disabledVal' should be a boolean (true/false)
function setMenuItemButtonsDisabledState(disabledVal)
{
    $('#detail1').prop("disabled", disabledVal);
    $('#detail2').prop('disabled', disabledVal);
    $('#add1').prop('disabled', disabledVal);
    $('#add2').prop('disabled', disabledVal);
}

// onchange event from a portion SSLB: send oid and new amount
function portionChange(selectElem, oid)
{
    var amt = selectElem.options[selectElem.selectedIndex].value
    // send new amount; render any errors w/ null id
    $.post('Menu.aspx/ChangePortion', { detailOid: oid, amount: amt }, function (data) { postCb(null, data); });
}

// onchange event from a uofm SSLB: send oid and new uofm
function setSelectedUofM(selectElem, oid)
{
    var uofmOid = selectElem.options[selectElem.selectedIndex].value
    // send new uofm; render any errors w/ null id
    $.post('Menu.aspx/ChangeUofM', { detailOid: oid, uofmOid: uofmOid }, function (data) { postCb(null, data); });
}

// Add the selected item(s) to "my meal"
function addToMyMeals(useNavBar)
{
    var form = Get_NN_Form()
    $.post('MyMeals.aspx/AddToMyMeal', form.serialize(), function (data) { postCb('myMeal', data); });
    if (useNavBar)
    {
        $.post('MyMeals.aspx/UpdateNavBar', null, function (data) { updateMyMealCount(data); });
        // will be ignored if button was not rendered
        $("#openMyMeal").prop('disabled', false);  
    }
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

// open my meal panel
function showMyMeals()
{
    erasePanel('nutritionGrid');
    $.post('MyMeals.aspx/MyMealList', null, function (data) { postCb('myMealPanel', data); });
}

// clse the nutrition label
function closeMyMealPanel()
{
    erasePanel('myMealPanel');
}

// open traits panel
function showTraits()
{
    erasePanel('traitsPanel');
    $.post('Trait.aspx/TraitList', null, function (data) { postCb('traitsPanel', data); });
}

// clse the nutrition label
function closeTraitsPanel()
{
    erasePanel('traitsPanel');
}

// close the nutritiongrid
function openNutritionPrintGrid() 
{
    gridWindow = window.open('./NutritionDetail.aspx/ShowItemNutritionPrintGrid/', 'NutritionPrintGrid','left=20,top=20,width=850,height=600,toolbar=1,resizable=1,menubar=1,scrollbars=1');
}

// remove the given detail from my meal
function myMealRemove(oid, unitOid, uofmOid, useNavBar, isEmpty)
{
    $.post('MyMeals.aspx/RemoveItem', { detailOid: oid, unitOid: unitOid, uofmOid: uofmOid }, function (data) { postCb('myMeal', data); });
    if (useNavBar)
    {
        $.post('MyMeals.aspx/UpdateNavBar', null, function (data) { updateMyMealCount(data); });
        // will be ignored if button is not rendered
        $("#openMyMeal").prop('disabled', isEmpty); 
    }
}

// update the count in the navigation header
function updateMyMealCount(contents)
{
    $("#myMealCount").html(contents);
}

// change the portion for an item in my meal.
function myMealPortionChange(selectElem, unitOid, oid, uofmOid)
{
    var amt = selectElem.options[selectElem.selectedIndex].value
    // send new amount; render any errors w/ null id
    $.post('MyMeals.aspx/ChangePortion', { unitOid: unitOid, detailOid: oid, uofmOid: uofmOid, amount: amt }, function (data) { postCb(null, data); });
}

// clear the contents of "my meal"
function clearMyMeals(useNavBar)
{
    // note: the session state will clear the current menu checkboxes (if there are any)
    $.post('MyMeals.aspx/ClearMyMeal', null, function (data) { postCb('myMeal', data); });
    if (useNavBar) {
        $.post('MyMeals.aspx/UpdateNavBar', null, function (data) { updateMyMealCount(data); });
        $("#openMyMeal").prop('disabled', true); 
    }
    // this does all the booking in the browser (an alternative is to re-render the entiere page)
    if (isPanelDisplayed('itemPanel'))
    {
        // disable all the buttons
        setMenuItemButtonsDisabledState(true);

        // clear all the checkboxes and the corresponding portion ddlbs
        $('input[id^= "' + MENU_CHECKBOX_PREFIX + '"]:checked').each(function ()
        {
            this.checked = false;
            var oid = this.id.substring(3); // strip off 3 char prefix
        });
        
    }
}

// is the given panel div currently displayed?
function isPanelDisplayed(panelDivId)
{
    // if the item panel exists and is not empty, then it's open and displayed
    if ($('#' + panelDivId).length > 0)
    {
        if ($('#' + panelDivId).html().length != 0)
        {
            return true;
        }
    }
    return false;
}

// callback for a trait checkbox
function traitListCb(cbElem, oid)
{
    // toggle this checkbox back in session state
    var menuOpen = isPanelDisplayed('itemPanel');
    // if the item panel exists and is not empty refresh it
    $.post('Menu.aspx/SelectTrait', { detailOid: oid, menuOpen: menuOpen }, function (jSonData) { renderResponse(jSonData); });
}

// clear all filters so that all menu items will be shown
function clearFilters()
{
    $('input[id^=allergy]').attr('checked', false);
    $('input[id^=pref]').attr('checked', false);

    var menuOpen = isPanelDisplayed('itemPanel');
    $.post('Menu.aspx/ClearFilters', { menuOpen: menuOpen }, function (jSonData) { renderResponse(jSonData); });
}

// handle a course selection: render the corresponding menu details
function selectCourse(courseOid)
{
    $("#itemPanel").html(PLEASE_WAIT_HTML);
    $.post('Menu.aspx/SelectCourse', { oid: courseOid }, function (jSonData) { renderResponse(jSonData); });
}

// handle a goal radio button click
function selectGoal(radioBtn)
{
    $.post('NutritionGoals.aspx/SelectGoal', { oid: radioBtn.value }, function (data) { postCb(null, data); });
}

// handle a menu selection click from the menu list panel
function menuListSelectMenu(menuOid)
{
    $("#itemPanel").html(PLEASE_WAIT_HTML);
    $.post('Menu.aspx/SelectMenu', { menuOid: menuOid }, function (jSonData) { renderResponse(jSonData); });  
}

// handle a 'back' button click from the menu list panel
function menuListBackBtn()
{
    $.post('Menu.aspx/GoBackFromMenuList', null, function (jSonData) { renderResponse(jSonData); });
}

// handle a 'back' button click from the menu detail panel
function menuDetailBackBtn()
{
    $.post('Menu.aspx/GoBackFromMenuDetails', null, function (jSonData) { renderResponse(jSonData); });
}

// handle a 'back' button click from the courses panel
function courseListBackBtn()
{
    $.post('Menu.aspx/GoBackFromCourseList', null, function (jSonData) { renderResponse(jSonData); });
}

// handle a link click from the unit tree
function unitTreeSelectUnit(unitOid)
{
    $("#itemPanel").html(PLEASE_WAIT_HTML);
    $.post('Unit.aspx/SelectUnitFromTree', { unitOid: unitOid }, function (jSonData) { renderResponse(jSonData); });
}

// handle a link click in the unit side bar navigation panel
function sideBarSelectUnit(unitOid)
{
    $("#itemPanel").html(PLEASE_WAIT_HTML);
    $.post('Unit.aspx/SelectUnitFromSideBar', { unitOid: unitOid }, function (jSonData) { renderResponse(jSonData); });
}

// handle a link click in the child list panel
function childUnitsSelectUnit(unitOid)
{
    $("#itemPanel").html(PLEASE_WAIT_HTML);
    $.post('Unit.aspx/SelectUnitFromChildUnitsList', { unitOid: unitOid }, function (jSonData) { renderResponse(jSonData); });
}

// handle a back button click in the child list panel
function childUnitBackBtn()
{
    $.post('Unit.aspx/GoBackFromChildList', null, function (jSonData) { renderResponse(jSonData); });
}

// handle a back button click in the unit list panel
function unitBackBtn()
{
    $.post('Unit.aspx/GoBackFromUnitList', null, function (jSonData) { renderResponse(jSonData); });
}

// hanle a link click in the units panel
function unitsSelectUnit(unitOid)
{
    $("#itemPanel").html(PLEASE_WAIT_HTML);
    $.post('Unit.aspx/SelectUnitFromUnitsList', { unitOid: unitOid }, function (jSonData) { renderResponse(jSonData); });
}

// expand and collapse control for tree list
function setUnitTreeUnitState(unitOid) 
{
    $.post('Unit.aspx/SetUnitTreeUnitState', { unitOid: unitOid }, function (data) { postCb('sideUnitPanel', data); });
}

// render a post-back json response
function renderResponse(data)
{
    try
    {
        if (data)
        {
            if (data.success)
            {
                var panelArray = data.panels;                
                for (var index = 0; index < panelArray.length; index++)
                {
                    var keyPair = panelArray[index];
                    postCb(keyPair.id, keyPair.html);
                }
            }
            else 
            { 
                //catch bad post back after session timeout
                if (typeof data.errorID === "undefined") 
                {
                    $.post('Home.aspx/StartOver', null, function (data) { });
                    window.location = "./home.aspx";
                }
                else {
                    // always erase the item panel because the "wait" gif goes there.
                    erasePanel("itemPanel");
                    postCb(data.errorID, data.errorHTML);
                }
                
            }
        }
    }
    catch (e)
    {
        alert("Exception: " + e.Message);
    }
}

// render the given static panel
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

// return the main form. 
function ChangeCulture(cultureName)
{
	$.post('Home.aspx/ChangeCultureOnThread', { CultureName: cultureName },
    function (data)
    {
    	if (data && data.length > 0)
    	{
    		alert(data);
    	}
    	window.location.reload(true);
    });
}
