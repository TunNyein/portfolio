// app.js

// 1. Visitor Counter Logic (API Call)
async function loadVisitorCount() {
  try {
    const res = await fetch("https://6ph4xzfuv7.execute-api.us-east-1.amazonaws.com/prod/counter");
    const data = await res.json();
    
    // Total Visitor : XXX 
    document.getElementById("visitor-counter").innerText = `${data.visits.toLocaleString()}`;
  } catch (err) {
    console.error("Visitor counter error:", err);
    // Error ရှိရင် "N/A" လို ပြပါမည်။
    document.getElementById("visitor-counter").innerText = "N/A"; 
  }
}

// 2. Navigation Active State Logic (Underline on scroll)
function setActiveNav() {
  const sections = document.querySelectorAll('.section');
  const navLinks = document.querySelectorAll('.nav-link');
  let current = '';

  sections.forEach(section => {
    // Offset slightly below the header for better activation point
    const sectionTop = section.offsetTop - 150; 
    
    if (window.scrollY >= sectionTop) {
      current = section.getAttribute('id');
    }
  });

  navLinks.forEach(a => {
    a.classList.remove('active');
    if (a.getAttribute('href').substring(1) === current) {
      a.classList.add('active');
    }
  });
}

// 3. Scroll Reveal Logic (Animate sections into view)
function scrollReveal() {
    const sections = document.querySelectorAll('.section');
    const triggerBottom = window.innerHeight * 0.8; 

    sections.forEach(section => {
        const sectionTop = section.getBoundingClientRect().top;
        
        if (sectionTop < triggerBottom) {
            section.classList.add('in-view');
        } else {
            section.classList.remove('in-view'); 
        }
    });
}


document.addEventListener("DOMContentLoaded", () => {
  loadVisitorCount();
  
  setActiveNav(); 
  scrollReveal(); 
  
  window.addEventListener('scroll', () => {
      setActiveNav(); 
      scrollReveal(); 
  });
});
