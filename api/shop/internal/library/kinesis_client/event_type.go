package kinesis_client

type EventType string

const (
	EventTypeCreateReservation      EventType = "create_reservation"
	EventTypeCreateReservationMulti EventType = "create_reservation_multi"
)
