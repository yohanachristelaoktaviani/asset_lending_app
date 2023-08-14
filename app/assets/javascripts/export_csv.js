document.addEventListener('DOMContentLoaded', function() {
  const exportCsvLink = document.getElementById('export-csv-link');

  exportCsvLink.addEventListener('click', function(event) {
    event.preventDefault();

    const url = this.href;

    fetch(url, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.blob())
    .then(blob => {
      const fileName = '<%= session[:csv_filename] || "export_data" %>.csv';
      const link = document.createElement('a');
      link.href = url;
      link.download = fileName;
      link.style.display = 'none';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    });
  });
});