<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Event;
use App\Models\TicketCategory;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Seed roles, permissions, and users
        $this->call(RolesAndPermissionsSeeder::class);

        // Get the super admin user for event creation
        $superAdmin = User::where('email', 'superadmin@matiko.com')->first();
        
        // Seed Events
        $this->seedEvents($superAdmin);
    }

    protected function seedEvents(User $creator): void
    {
        $event1 = Event::create([
            'name' => 'Summer Music Festival',
            'description' => 'A night of incredible live music and food.',
            'venue' => 'Nairobi City Park',
            'event_date' => now()->addDays(7)->toDateString(),
            'start_time' => '18:00:00',
            'end_time' => '23:59:59',
            'status' => 'upcoming',
            'created_by' => $creator->id,
        ]);

        TicketCategory::create([
            'event_id' => $event1->id,
            'name' => 'Regular',
            'price' => 1500.00,
            'quantity' => 400,
        ]);

        TicketCategory::create([
            'event_id' => $event1->id,
            'name' => 'VIP',
            'price' => 5000.00,
            'quantity' => 100,
        ]);

        $event2 = Event::create([
            'name' => 'Tech Summit 2026',
            'description' => 'Joining the top minds in AI and Web3.',
            'venue' => 'KICC, Nairobi',
            'event_date' => now()->addDays(30)->toDateString(),
            'start_time' => '08:00:00',
            'end_time' => '17:00:00',
            'status' => 'upcoming',
            'created_by' => $creator->id,
        ]);

        TicketCategory::create([
            'event_id' => $event2->id,
            'name' => 'Early Bird',
            'price' => 3000.00,
            'quantity' => 200,
        ]);

        TicketCategory::create([
            'event_id' => $event2->id,
            'name' => 'Full Pass',
            'price' => 6000.00,
            'quantity' => 800,
        ]);
    }
}
