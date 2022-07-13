class Receipt {
  int receiptId;
  double transferAmount;
  String issuedAt;
  int serviceId;
  bool isReceived;
  int transactionType;

  Receipt(
      {this.receiptId,
      this.transferAmount,
      this.issuedAt,
      this.serviceId,
      this.isReceived,
      this.transactionType});
}
