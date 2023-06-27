# YAML options

# https://quarto.org/docs/output-formats/ms-word.html
# Word
---
title: "Quarto Example"
author: "Tim Essam & Karishma Srikanth"
format:
  docx:
  toc: true
  number-sections: true
  highlight-style: github
---
  
  
# https://quarto.org/docs/output-formats/html-basics.html
# HTML  
---
title: "Quarto Example"
author: "Tim Essam & Karishma Srikanth"
format:
  html:
    toc: true
    html-math-method: katex
    css: styles.css
---
  
  
# HTLM with code folding
---
title: "Quarto Example"
author: "Tim Essam & Karishma Srikanth"
format:
  html:
    code-tools: true
    code-fold: true
    theme: spacelab
---
    