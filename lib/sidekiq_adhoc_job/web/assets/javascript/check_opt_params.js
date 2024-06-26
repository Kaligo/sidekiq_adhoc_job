document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById('adhoc-jobs-submit-form');
  form.addEventListener('submit', function (event) {
    const optionalArgs = document.querySelectorAll('.optional');
    for (let i = 0; i < optionalArgs.length; i++) {
      if (optionalArgs[i].value.trim() === '') {
        for (let j = i + 1; j < optionalArgs.length; j++) {
          if (optionalArgs[j].value.trim() !== '') {
            event.preventDefault();
            alert('Please do not leave empty optional parameters when there are non-empty parameters after it');
            return;
          }
        }
      }
    }
  });
});
