
document.getElementById('adhoc-jobs-submit-form').addEventListener('submit', (event) => {
  const confirmPrompt = document.getElementById('presented-job').getAttribute('data-confirm-prompt');
  const input = prompt(`Please enter "${confirmPrompt}" to confirm`);
  if (input !== confirmPrompt) {
    event.preventDefault();
    if (input !== null) {
      alert('Your confirmation input is incorrect, try again.');
    }
  }
})
