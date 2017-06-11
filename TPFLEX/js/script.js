
function oL(name) {
    var list = document.getElementById(name);
    var style = window.getComputedStyle(list, null);

    if (style.display == "none")
        list.style.display = "block";
    else
        list.style.display = "none";
}