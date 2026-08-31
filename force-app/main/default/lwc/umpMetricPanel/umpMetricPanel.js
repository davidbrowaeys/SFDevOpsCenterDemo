/**
 * @author David Browaeys
 * @date 2026-02-04
 * @description Universal Metric Panel LWC - displays configurable metrics with donut chart
 */
import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getPanelData from "@salesforce/apex/UMP_MetricPanel_Ctrl.getPanelData";

// Custom Labels for translation support
import labelLoading from "@salesforce/label/c.UMP_Loading";
import labelErrorOccurred from "@salesforce/label/c.UMP_Error_Occurred";
import labelDefaultTitle from "@salesforce/label/c.UMP_Default_Title";
import labelDefaultItems from "@salesforce/label/c.UMP_Default_Items";
import labelTitleFor from "@salesforce/label/c.UMP_Title_For";
import labelLastQuarter from "@salesforce/label/c.UMP_Last_Quarter";
import labelThisQuarter from "@salesforce/label/c.UMP_This_Quarter";
import labelViewAll from "@salesforce/label/c.UMP_View_All";

export default class UmpMetricPanel extends NavigationMixin(LightningElement) {
  @api recordId;
  @api configName;
  @api panelTitle;
  @api donutTitleOverride;
  @api metricLabel1; // Override label for first metric (by display order)
  @api metricLabel2; // Override label for second metric (by display order)
  @api panelBackground; // Custom background CSS value
  @api hideWhenEmpty = false;

  // Default background gradient
  DEFAULT_BACKGROUND = "linear-gradient(135deg, #0d1b3e 0%, #1a2f5a 100%)";

  panelData;
  error;
  isLoading = true;

  // Expose labels for template
  labels = {
    loading: labelLoading,
    errorOccurred: labelErrorOccurred,
    defaultTitle: labelDefaultTitle,
    defaultItems: labelDefaultItems,
    titleFor: labelTitleFor,
    lastQuarter: labelLastQuarter,
    thisQuarter: labelThisQuarter,
    viewAll: labelViewAll
  };

  @wire(getPanelData, {
    recordId: "$recordId",
    configDeveloperName: "$configName"
  })
  wiredPanelData({ error, data }) {
    this.isLoading = false;
    if (data) {
      this.panelData = data;
      this.error = undefined;
    } else if (error) {
      this.error = error.body?.message || this.labels.errorOccurred;
      this.panelData = undefined;
    }
  }

  get hasData() {
    return this.panelData && !this.error;
  }

  /**
   * Determines if the panel should be visible
   * Returns false if hideWhenEmpty is true and there is no data (totalCount is 0)
   */
  get showPanel() {
    if (this.isLoading) {
      return true;
    }
    if (this.hideWhenEmpty && (!this.panelData || this.totalCount === 0)) {
      return false;
    }
    return true;
  }

  /**
   * Returns the loading spinner alternative text
   */
  get loadingText() {
    return this.labels.loading;
  }

  /**
   * Returns the last quarter label
   */
  get lastQuarterLabel() {
    return this.labels.lastQuarter;
  }

  /**
   * Returns the this quarter label
   */
  get thisQuarterLabel() {
    return this.labels.thisQuarter;
  }

  /**
   * Returns the view all link text with donut title
   */
  get viewAllText() {
    return `${this.labels.viewAll} ${this.donutTitle}`;
  }

  get displayTitle() {
    if (this.panelTitle) {
      return this.panelTitle;
    }
    if (this.panelData?.donutTitle && this.panelData?.parentName) {
      return `${this.donutTitle} ${this.labels.titleFor} ${this.panelData.parentName}`;
    }
    return this.labels.defaultTitle;
  }

  /**
   * Returns the donut title - checks override first, then metadata, then default label
   */
  get donutTitle() {
    if (this.donutTitleOverride) {
      return this.donutTitleOverride;
    }
    return this.panelData?.donutTitle || this.labels.defaultItems;
  }

  get totalCount() {
    return this.panelData?.totalCount || 0;
  }

  get donutSegments() {
    return this.panelData?.donutSegments || [];
  }

  /**
   * Returns metrics with optional label overrides applied
   * Uses metricLabel1 for first metric and metricLabel2 for second metric (by display order)
   */
  get metrics() {
    const rawMetrics = this.panelData?.metrics || [];
    const labelOverrides = [this.metricLabel1, this.metricLabel2];

    return rawMetrics.map((metric, index) => ({
      ...metric,
      label: labelOverrides[index] || metric.label
    }));
  }

  get donutTitleWithCount() {
    const title = this.donutTitle;
    const count = this.panelData?.totalCount || 0;
    return `${title} (${count})`;
  }

  /**
   * Returns the panel container style with configurable background
   */
  get panelContainerStyle() {
    const background = this.panelBackground || this.DEFAULT_BACKGROUND;
    return `background: ${background}; background-color: ${background}`;
  }

  /**
   * Generates SVG path data for donut chart segments
   */
  get donutChartSegments() {
    const segments = this.donutSegments;
    if (!segments || segments.length === 0) {
      return [];
    }

    const total = segments.reduce((sum, seg) => sum + seg.count, 0);
    if (total === 0) {
      return [];
    }

    const result = [];
    let currentAngle = -90; // Start from top
    const cx = 50;
    const cy = 50;
    const outerRadius = 45;
    const innerRadius = 32;

    segments.forEach((segment, index) => {
      const percentage = segment.count / total;
      const angle = percentage * 360;
      const endAngle = currentAngle + angle;

      // Calculate arc path
      const startAngleRad = (currentAngle * Math.PI) / 180;
      const endAngleRad = (endAngle * Math.PI) / 180;

      const x1Outer = cx + outerRadius * Math.cos(startAngleRad);
      const y1Outer = cy + outerRadius * Math.sin(startAngleRad);
      const x2Outer = cx + outerRadius * Math.cos(endAngleRad);
      const y2Outer = cy + outerRadius * Math.sin(endAngleRad);

      const x1Inner = cx + innerRadius * Math.cos(endAngleRad);
      const y1Inner = cy + innerRadius * Math.sin(endAngleRad);
      const x2Inner = cx + innerRadius * Math.cos(startAngleRad);
      const y2Inner = cy + innerRadius * Math.sin(startAngleRad);

      const largeArcFlag = angle > 180 ? 1 : 0;

      // Create donut segment path
      const pathData = [
        `M ${x1Outer} ${y1Outer}`,
        `A ${outerRadius} ${outerRadius} 0 ${largeArcFlag} 1 ${x2Outer} ${y2Outer}`,
        `L ${x1Inner} ${y1Inner}`,
        `A ${innerRadius} ${innerRadius} 0 ${largeArcFlag} 0 ${x2Inner} ${y2Inner}`,
        "Z"
      ].join(" ");

      result.push({
        id: `segment-${index}`,
        path: pathData,
        color: segment.color,
        label: segment.label,
        count: segment.count,
        percentage: segment.percentage
      });

      currentAngle = endAngle;
    });

    return result;
  }

  /**
   * Generates legend items with color indicators
   */
  get legendItems() {
    return this.donutSegments.map((segment, index) => ({
      id: `legend-${index}`,
      label: segment.label,
      count: segment.count,
      color: segment.color,
      dotStyle: `background-color: ${segment.color}`,
      displayText: `${segment.count} ${segment.label}`
    }));
  }

  /**
   * Handles View All link click - navigates to related list
   */
  handleViewAll() {
    if (!this.panelData?.childObjectApiName || !this.recordId) {
      return;
    }

    this[NavigationMixin.Navigate]({
      type: "standard__recordRelationshipPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: this.panelData.childObjectApiName,
        relationshipApiName: this.getRelationshipName()
      }
    });
  }

  /**
   * Gets the relationship name for navigation
   */
  getRelationshipName() {
    // For standard objects like Opportunity, the relationship is typically 'Opportunities'
    const childObject = this.panelData?.childObjectApiName;
    if (childObject === "Opportunity") {
      return "Opportunities";
    }
    if (childObject === "Contact") {
      return "Contacts";
    }
    if (childObject === "Case") {
      return "Cases";
    }
    // For custom objects, append __r
    if (childObject?.endsWith("__c")) {
      return childObject.replace("__c", "__r");
    }
    return childObject + "s";
  }
}
