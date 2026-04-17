"""
Rapid Aid — WebSocket Consumers
Real-time communication for the dispatch dashboard and responder tracking.
"""

import json
import logging

from channels.generic.websocket import AsyncJsonWebsocketConsumer

logger = logging.getLogger(__name__)


class IncidentConsumer(AsyncJsonWebsocketConsumer):
    """
    WebSocket consumer for real-time incident updates.

    Groups:
        - 'dispatch_dashboard': All dispatchers receive new/updated incidents.
        - 'incident_{id}': Subscribers to a specific incident's updates.
        - 'responder_{user_id}': Direct channel to a specific responder.

    Message types:
        - incident.new: A new incident has been reported.
        - incident.update: An incident's status has changed.
        - incident.assign: A responder has been assigned to an incident.
        - responder.location: A responder's location has been updated.
    """

    async def connect(self):
        """Accept connection and add to dispatch dashboard group."""
        self.user = self.scope.get('user')

        # Join the dispatch dashboard group for all real-time updates
        await self.channel_layer.group_add(
            'dispatch_dashboard',
            self.channel_name,
        )

        # If the user is a responder, add them to their personal channel
        if self.user and hasattr(self.user, 'role') and self.user.role == 'RESPONDER':
            await self.channel_layer.group_add(
                f'responder_{self.user.id}',
                self.channel_name,
            )

        await self.accept()
        logger.info(f'WebSocket connected: {self.channel_name}')

    async def disconnect(self, close_code):
        """Leave all groups on disconnect."""
        await self.channel_layer.group_discard(
            'dispatch_dashboard',
            self.channel_name,
        )

        if self.user and hasattr(self.user, 'id'):
            await self.channel_layer.group_discard(
                f'responder_{self.user.id}',
                self.channel_name,
            )

        logger.info(f'WebSocket disconnected: {self.channel_name} (code={close_code})')

    async def receive_json(self, content, **kwargs):
        """
        Handle incoming WebSocket messages from clients.

        Expected payload:
            {"type": "subscribe_incident", "incident_id": 123}
            {"type": "responder_location", "latitude": 6.5, "longitude": 3.3}
        """
        msg_type = content.get('type')

        if msg_type == 'subscribe_incident':
            incident_id = content.get('incident_id')
            if incident_id:
                await self.channel_layer.group_add(
                    f'incident_{incident_id}',
                    self.channel_name,
                )
                await self.send_json({
                    'type': 'subscribed',
                    'incident_id': incident_id,
                })

        elif msg_type == 'responder_location':
            # Broadcast location update to the dispatch dashboard
            await self.channel_layer.group_send(
                'dispatch_dashboard',
                {
                    'type': 'responder.location',
                    'user_id': self.user.id if self.user else None,
                    'latitude': content.get('latitude'),
                    'longitude': content.get('longitude'),
                },
            )

    # ── Group message handlers ──────────────────────────────

    async def incident_new(self, event):
        """Send new incident notification to client."""
        await self.send_json(event)

    async def incident_update(self, event):
        """Send incident status update to client."""
        await self.send_json(event)

    async def incident_assign(self, event):
        """Send assignment notification to client."""
        await self.send_json(event)

    async def responder_location(self, event):
        """Send responder location update to client."""
        await self.send_json(event)
