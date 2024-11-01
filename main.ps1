


# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

function New-UDFChart {
    param([hashtable]$fromSender)
    $Charts = @{
        Storage = @{
            Chart = @{
                Width       = 700
                Height      = 450
                BackColor    = [System.Drawing.Color]::LightBlue
            }
            Area = @{
                BackColor    = [System.Drawing.Color]::LightBlue
            }
            Axis = @{
                X = @{
                    Title = "Drives"
                }
                Y = @{
                    Title = "Space (GB)" 
                }
            }
            Series = @{
                UsedSpace = @{
                    ChartType   = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedBar
                    Name        = "Space Used"
                    Color       = [System.Drawing.Color]::Green
                }
                AvailableSpace = @{
                    ChartType   = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedBar
                    Name        = "Space Available"
                    Color       = [System.Drawing.Color]::Blue
                }
            }
        }
    }

    if($fromSender.Chart -eq "Storage"){
        $chart              = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
        $chart.Width        = $Charts.Storage.Chart.Width
        $chart.Height       = $Charts.Storage.Chart.Height
        
        $chart.BackColor    = $Charts.Storage.Chart.BackColor

        $chartArea              = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $chartArea.BackColor    = $Charts.Storage.Area.BackColor
        $chart.ChartAreas.Add($chartArea)

        $usedSpaceSeries            = New-Object System.Windows.Forms.DataVisualization.Charting.Series
        $usedSpaceSeries.ChartType  = $Charts.Storage.Series.UsedSpace.ChartType
        $usedSpaceSeries.Name       = $Charts.Storage.Series.UsedSpace.Name
        $usedSpaceSeries.Color      = $Charts.Storage.Series.UsedSpace.Color

        $availableSpaceSeries           = New-Object System.Windows.Forms.DataVisualization.Charting.Series
        $availableSpaceSeries.ChartType  = $Charts.Storage.Series.AvailableSpace.ChartType
        $availableSpaceSeries.Name       = $Charts.Storage.Series.AvailableSpace.Name
        $availableSpaceSeries.Color      = $Charts.Storage.Series.AvailableSpace.Color

        $chart.Series.Add($usedSpaceSeries)
        $chart.Series.Add($availableSpaceSeries)

        $chartArea.AxisY.LineWidth = 0
        $chartArea.AxisX.LineWidth = 0
        $chartArea.AxisX.MajorGrid.LineDashStyle    = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Dash
$chartArea.AxisX.MajorGrid.LineColor        = [System.Drawing.Color]::Gray  # Set grid line color (optional)
$chartArea.AxisX.MajorGrid.LineWidth        = 2

# Customize the Y-axis grid lines
$chartArea.AxisY.MajorGrid.LineDashStyle    = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Dash
$chartArea.AxisY.MajorGrid.LineColor        = [System.Drawing.Color]::Gray  # Set grid line color (optional)
$chartArea.AxisY.MajorGrid.LineWidth        = 2  # Set grid line thickness

# Customize the X-axis minor grid lines
$chartArea.AxisX.MinorGrid.Enabled          = $true
$chartArea.AxisX.MinorGrid.LineDashStyle    = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Dash
$chartArea.AxisX.MinorGrid.LineColor        = [System.Drawing.Color]::Black
$chartArea.AxisX.MinorGrid.LineWidth        = 1

# Customize the Y-axis minor grid lines
$chartArea.AxisY.MinorGrid.Enabled          = $true
$chartArea.AxisY.MinorGrid.LineDashStyle    = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Dash
$chartArea.AxisY.MinorGrid.LineColor        = [System.Drawing.Color]::black
$chartArea.AxisY.MinorGrid.LineWidth        = 1
        $chartArea.AxisX.Title = $Charts.Storage.Axis.X.Title
        $chartArea.AxisY.Title = $Charts.Storage.Axis.Y.Title

        $legend         = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
        $legend.BackColor = [System.Drawing.Color]::LightBlue
        $legend.Docking = [System.Windows.Forms.DataVisualization.Charting.Docking]::Top  # Position the legend at the top
        $chart.Legends.Add($legend)
        $chart
    }
}

# Create a new form
$form           = New-Object System.Windows.Forms.Form
$form.Text      = "Real-Time Spline Chart"
$form.Width     = 900
$form.Height    = 600
$form.BackColor = [System.Drawing.Color]::LightBlue

$storageChart1 = New-UDFChart @{Chart = "Storage"}

# Create a GroupBox to hold the chart
$groupBox           = New-Object System.Windows.Forms.GroupBox
$groupBox.Text      = "Chart Group"  # Title for the group
$groupBox.Width     = 800
$groupBox.Height    = 540
$groupBox.Location  = New-Object System.Drawing.Point(10, 10)  # Position of the group box

$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Text     = "Chart Group"  # Title for the group
$groupBox1.Width    = 800
$groupBox1.Height   = 540
$groupBox1.Location = New-Object System.Drawing.Point(810, 10)  # Position of the group box


# Create a chart area
$chart              = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$chart.Width        = 750
$chart.Height       = 500
$chart.Location     = New-Object System.Drawing.Point(30, 30)  # Position of the group box
$chart.BackColor    = [System.Drawing.Color]::LightBlue

# Set up the chart area and series for a spline chart
$chartArea              = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$chartArea.BackColor    = [System.Drawing.Color]::LightBlue

# Customize the X-axis grid lines
$chartArea.AxisX.MajorGrid.LineDashStyle    = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Dash
$chartArea.AxisX.MajorGrid.LineColor        = [System.Drawing.Color]::Gray  # Set grid line color (optional)
$chartArea.AxisX.MajorGrid.LineWidth        = 2

# Customize the Y-axis grid lines
$chartArea.AxisY.MajorGrid.LineDashStyle    = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Dash
$chartArea.AxisY.MajorGrid.LineColor        = [System.Drawing.Color]::Gray  # Set grid line color (optional)
$chartArea.AxisY.MajorGrid.LineWidth        = 2  # Set grid line thickness

# Customize the X-axis minor grid lines
$chartArea.AxisX.MinorGrid.Enabled          = $true
$chartArea.AxisX.MinorGrid.LineDashStyle    = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Dash
$chartArea.AxisX.MinorGrid.LineColor        = [System.Drawing.Color]::Black
$chartArea.AxisX.MinorGrid.LineWidth        = 1

# Customize the Y-axis minor grid lines
$chartArea.AxisY.MinorGrid.Enabled          = $true
$chartArea.AxisY.MinorGrid.LineDashStyle    = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Dash
$chartArea.AxisY.MinorGrid.LineColor        = [System.Drawing.Color]::black
$chartArea.AxisY.MinorGrid.LineWidth        = 1

$chartArea.AxisY.LineWidth = 0
$chartArea.AxisX.LineWidth = 0


$chart.ChartAreas.Add($chartArea)


$series             = New-Object System.Windows.Forms.DataVisualization.Charting.Series
$series.ChartType   = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Spline

$series.Name        = "Random Data"
$series.BorderWidth = 3

$chart.Series.Add($series)


# Create and customize the legend
$legend             = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
$legend.BackColor   = [System.Drawing.Color]::LightBlue 
$legend.Docking     = [System.Windows.Forms.DataVisualization.Charting.Docking]::Top  # Position the legend at the top
$chart.Legends.Add($legend)

# Add the series to the legend
$series.Legend = $legend.Name  # Associate the series with the legend


# Add labels to the X and Y axes
$chartArea.AxisX.Title = "X-Axis Label"  # Set X-axis label
$chartArea.AxisY.Title = "Y-Axis Label"  # Set Y-axis label

# Optional: Customize axis titles' font size and color
$chartArea.AxisX.TitleFont      = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$chartArea.AxisY.TitleFont      = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$chartArea.AxisX.TitleForeColor = [System.Drawing.Color]::Blue  # Change color for X-axis title
$chartArea.AxisY.TitleForeColor = [System.Drawing.Color]::Red   # Change color for Y-axis title

# Add a title to the chart
$title = New-Object System.Windows.Forms.DataVisualization.Charting.Title
$title.Text         = "Sample Line Chart Title"  # Set your chart title here
$title.Font         = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)  # Set font size and style
$title.ForeColor    = [System.Drawing.Color]::Black  # Set title color
$chart.Titles.Add($title)  # Add title to the chart

# Add the chart to the GroupBox
$groupBox.Controls.Add($chart)
$groupBox1.Controls.Add($storageChart1)
# Add the GroupBox to the form
$form.Controls.Add($groupBox1)
$form.Controls.Add($groupBox)
# Add the chart to the form
#$form.Controls.Add($chart)

# Initialize data and a timer to update the chart
$dataPoints = New-Object System.Collections.ArrayList


$maxPoints = 100  # Maximum number of points to display

# Create a timer to update the chart every second
$timer          = New-Object System.Windows.Forms.Timer
$timer.Interval = 50  # 1 second

# Timer tick event to update the chart
$timer.Add_Tick({
    # Generate a new random data point (replace with actual data if available)
    $cursorY = [System.Windows.Forms.Cursor]::Position.Y
    $dataPoints.Add($cursorY) | Out-Null
    #$dataPoints.Add((Get-Process).count)
    # Keep only the last $maxPoints number of points
    if ($dataPoints.Count -gt $maxPoints) {
        $dataPoints.RemoveAt(0)
    }
    # Update the chart data
    $series.Points.Clear()
    $dataPoints | ForEach-Object { $series.Points.AddY($_) }
    # Redraw the chart
    $chart.Invalidate()

            # Update the chart data
            ($storageChart1.Series | Where-Object {$_.Name -eq "Space Available"}).Points.Clear()
            ($storageChart1.Series | Where-Object {$_.Name -eq "Space Used"}).Points.Clear()
         
        $dataPoints = @(
            @{ Drive = "C:"; Used = 40; Available = 60 },
            @{ Drive = "D:"; Used = 30; Available = 70 },
            @{ Drive = "E:"; Used = 50; Available = 50 },
            @{ Drive = "F:"; Used = 20; Available = 80 }
        )

        $Used = (($cursorY)/100) * 10
        $available = 100 - $used
        $dataPoints[0].Used = $used
        $dataPoints[0].Available = $available

        $Used = (($cursorY)/100) * 10
        $available = 100 - $used
        $dataPoints[1].Used = $used - (Get-Random -min 0 -Maximum 10)
        $dataPoints[1].Available = $available

        $Used = (([System.Windows.Forms.Cursor]::Position.Y)/100) * 10
        $available = 100 - $used + 10
        $dataPoints[2].Used = $used - (Get-Random -min 0 -Maximum 10)
        $dataPoints[2].Available = $available

        $Used = (([System.Windows.Forms.Cursor]::Position.Y)/100) * 10
        $available = 100 - $used - 15
        $dataPoints[3].Used = $used- (Get-Random -min 0 -Maximum 10)
        $dataPoints[3].Available = $available

        foreach ($point in $dataPoints) {
            ($storageChart1.Series | Where-Object {$_.Name -eq "Space Available"}).Points.AddXY($point.Drive, $point.Used)
            ($storageChart1.Series | Where-Object {$_.Name -eq "Space Used"}).Points.AddXY($point.Drive, $point.Available)
        }
})

# Start the timer
$timer.Start()

# Show the form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
