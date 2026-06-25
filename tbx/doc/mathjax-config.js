// MathJax configuration
window.MathJax = {
    tex: {
    inlineMath: [['$', '$'], ['\\(', '\\)']],
    displayMath: [['$$', '$$'], ['\\[', '\\]']]
    }
    };

// Dynamically load MathJax
(function () {
const script = document.createElement('script');
script.src = "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js";
script.async = true;
document.head.appendChild(script);
})();