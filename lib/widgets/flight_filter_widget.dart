import 'package:flutter/material.dart';
import '../models/flight_filter.dart';

class FlightFilterWidget extends StatefulWidget {
  final FlightFilter initialFilter;
  final Function(FlightFilter) onFilterChanged;
  final bool showOnlyAvailable;
  final String buttonLabel;

  const FlightFilterWidget({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
    this.showOnlyAvailable = false,
    this.buttonLabel = 'Suchen',
  });

  @override
  State<FlightFilterWidget> createState() => _FlightFilterWidgetState();
}

class _FlightFilterWidgetState extends State<FlightFilterWidget> {
  late TextEditingController _departureController;
  late TextEditingController _arrivalController;
  late TextEditingController _dateController;
  late TextEditingController _airlineController;
  late TextEditingController _maxPriceController;
  late TextEditingController _fromTimeController;
  late TextEditingController _toTimeController;
  late bool _onlyAvailable;

  @override
  void initState() {
    super.initState();
    _departureController = TextEditingController(text: widget.initialFilter.departureLocation);
    _arrivalController = TextEditingController(text: widget.initialFilter.arrivalLocation);
    _dateController = TextEditingController(text: widget.initialFilter.departureDate);
    _airlineController = TextEditingController(text: widget.initialFilter.airline);
    _maxPriceController = TextEditingController(text: widget.initialFilter.maxPrice?.toString() ?? '');
    _fromTimeController = TextEditingController(text: widget.initialFilter.fromTime);
    _toTimeController = TextEditingController(text: widget.initialFilter.toTime);
    _onlyAvailable = widget.initialFilter.onlyAvailable;
  }

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    _dateController.dispose();
    _airlineController.dispose();
    _maxPriceController.dispose();
    _fromTimeController.dispose();
    _toTimeController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final filter = FlightFilter(
      departureLocation: _departureController.text,
      arrivalLocation: _arrivalController.text,
      departureDate: _dateController.text,
      airline: _airlineController.text,
      maxPrice: double.tryParse(_maxPriceController.text),
      fromTime: _fromTimeController.text,
      toTime: _toTimeController.text,
      onlyAvailable: _onlyAvailable,
    );
    widget.onFilterChanged(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _departureController,
                decoration: const InputDecoration(labelText: 'Abreiseort', prefixIcon: Icon(Icons.flight_takeoff)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _arrivalController,
                decoration: const InputDecoration(labelText: 'Zielort', prefixIcon: Icon(Icons.flight_land)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Datum (YYYY-MM-DD)', prefixIcon: Icon(Icons.calendar_today)),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = pickedDate.toString().split(' ')[0];
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _airlineController,
                decoration: const InputDecoration(labelText: 'Airline', prefixIcon: Icon(Icons.business)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _maxPriceController,
                decoration: const InputDecoration(labelText: 'Max. Preis', prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fromTimeController,
                      decoration: const InputDecoration(labelText: 'Ab Zeit', prefixIcon: Icon(Icons.access_time)),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 0, minute: 0),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _fromTimeController.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _toTimeController,
                      decoration: const InputDecoration(labelText: 'Bis Zeit', prefixIcon: Icon(Icons.access_time)),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 23, minute: 59),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _toTimeController.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.showOnlyAvailable) ...[
                    Checkbox(
                      value: _onlyAvailable,
                      onChanged: (bool? value) => setState(() => _onlyAvailable = value ?? false),
                    ),
                    const Text('Nur verfügbare'),
                  ],
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _applyFilter,
                    icon: const Icon(Icons.search),
                    label: Text(widget.buttonLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
