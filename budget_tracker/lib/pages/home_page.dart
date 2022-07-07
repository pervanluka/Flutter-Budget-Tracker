import 'package:budget_tracker/model/transaction_item.dart';
import 'package:budget_tracker/view_models/budget_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AddTransactionDialog(
                      itemToAdd: (transactionItem) {
                        final budgetService = Provider.of<BudgetViewModel>(
                            context,
                            listen: false);
                        budgetService.addItem(transactionItem);
                        /* setState(() {
                          items.add(transactionItem); BEFORE EDITING BUDGET_SERVICE
                        }); */
                      },
                    ));
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: screenSize.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: Consumer<BudgetViewModel>(
                          builder: ((context, value, child) {
                            final budget = value.getBudget();
                            final balance = value.getBudget() + value.getBalance();
                            double percentage = balance / budget;
                            if (percentage < 0) {
                              percentage = 0;
                            }
                            if (percentage > 1) {
                              percentage = 1;
                            }
                            return CircularPercentIndicator(
                              radius: screenSize.width / 3.5,
                              lineWidth: 10.0,
                              percent: percentage,
                              backgroundColor: Colors.white,
                              center: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${balance.toString().split('.')[0]} BAM",
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Balance",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    "Budget: ${budget.toString()} BAM",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              progressColor:
                                  Theme.of(context).colorScheme.primary,
                            );
                          }),
                        )),
                    const SizedBox(
                      height: 35,
                    ),
                    const Text(
                      "Items",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Consumer<BudgetViewModel>(builder: (context, value, child) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: value.items.length,
                        itemBuilder: (context, index) {
                          return TransactionCard(item: value.items[index]);
                        },
                      );
                    })
                    /* ...List.generate(
                        items.length,
                        (index) => TransactionCard(   BEFORE EDITING BUDGET_SERVICE
                              item: items[index],
                            )) */
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionItem item;
  const TransactionCard({required this.item, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(children: [
                  const Text("Delete item"),
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        final budgetViewModel = Provider.of<BudgetViewModel>(
                            context,
                            listen: false);
                        budgetViewModel.deleteItem(item);
                        Navigator.pop(context);
                      },
                      child: const Text("Yes")),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No"))
                ]),
              ),
            );
          })),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, top: 5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                offset: const Offset(0, 25),
                blurRadius: 50,
              )
            ],
          ),
          padding: const EdgeInsets.all(15.0),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Text(
                item.itemTitle,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Text(
                (!item.isExpense ? "+ " : "- ") + item.amount.toString(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(TransactionItem) itemToAdd;
  const AddTransactionDialog({required this.itemToAdd, Key? key})
      : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController _itemTitleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isExpenseController = true;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(15),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.3,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Add an expense",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                controller: _itemTitleController,
                decoration: const InputDecoration(hintText: "Name of expense"),
              ),
              TextField(
                controller: _amountController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(hintText: "Amount in BAM"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Is expense?"),
                  Switch.adaptive(
                    value: _isExpenseController,
                    onChanged: (b) {
                      setState(() {
                        _isExpenseController = b;
                      });
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: (() {
                    if (_itemTitleController.text.isNotEmpty &&
                        _amountController.text.isNotEmpty) {
                      widget.itemToAdd(TransactionItem(
                          amount: double.parse(_amountController.text),
                          itemTitle: _itemTitleController.text,
                          isExpense: _isExpenseController));

                      //Dismiss Dialog
                      Navigator.pop(context);
                    }
                  }),
                  child: const Text("Add"))
            ],
          ),
        ),
      ),
    );
  }
}
