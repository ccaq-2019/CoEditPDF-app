var canvas = document.getElementById("canvas");
var canvas_container = document.getElementById("canvas-container");
var pdf_viewer = document.getElementById("pdf-viewer");

function createInput(x, y) {
    var input = document.createElement("input");
    input.setAttribute("type", "text");
    input.setAttribute("style", `position:absolute; left:${x}px; top:${y}px; background-color:transparent; border-style:dashed; border-color:gray;`);
    return input;
}

function addInputTextToCanvas(input) {
    var ctx = canvas.getContext("2d");

    // Set font
    let fontSize = window.getComputedStyle(input).fontSize;
    let fontFamily = window.getComputedStyle(input).fontFamily.split(',')[0];
    ctx.font = `${fontSize} ${fontFamily}`;

    ctx.fillText(input.value, input.offsetLeft + 2, input.offsetTop + 20); // 2px and 20px for correction
}

function postInput(input) {
    pdf_id = pdf_viewer.getAttribute("src").split('/')[2];
    $.post(`/pdfs/${pdf_id}/edit`,
           {text: input.value, x: input.offsetLeft + 1, y: input.offsetTop + 22},
           dataType="json"
    );
}

// Set canvas size as its container div
canvas.width = window.getComputedStyle(canvas_container).width.replace("px", "");
canvas.height = window.getComputedStyle(canvas_container).height.replace("px", "");

var editing = false;
canvas.addEventListener('mouseup', e => {
    // Get mouse position
    const rect = canvas.getBoundingClientRect();
    let x = e.clientX - rect.left;
    let y = e.clientY - rect.top - 15; // 15px for correction

    if (!editing) {
        editing = true;
        // Show an input box
        var input = createInput(x, y);
        canvas_container.appendChild(input);
        input.focus();
    } else {
        editing = false;
        var inputElement = canvas_container.getElementsByTagName("input")[0];
    
        if (inputElement instanceof HTMLInputElement) { // If input element not null
            if (inputElement.value.length > 0) { // If input not empty
                addInputTextToCanvas(inputElement);
                postInput(inputElement);
            }

            canvas_container.removeChild(inputElement);
        }
    }
});

// $(document).ready(function() {
    
// });
