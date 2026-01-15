<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RolesAndPermissionsSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create permissions
        $permissions = [
            // Ticket Management
            'buy tickets',
            'view own tickets',
            
            // Ticket Scanning & Verification
            'scan tickets',
            'verify tickets',
            'check-in tickets',
            
            // Payment Operations
            'initiate stk push',
            'process payments',
            
            // Event Management
            'view events',
            'create events',
            'edit events',
            'delete events',
            'manage ticket categories',
            
            // Agent Management
            'view agents',
            'create agents',
            'edit agents',
            'delete agents',
            'assign agents to events',
            
            // User Management
            'view users',
            'create users',
            'edit users',
            'delete users',
            'manage user roles',
            
            // Order Management
            'view all orders',
            'view own orders',
            'manage orders',
            
            // Reports & Analytics
            'view reports',
            'export data',
            
            // System Settings
            'manage settings',
            'view audit logs',
        ];

        foreach ($permissions as $permission) {
            Permission::create(['name' => $permission]);
        }

        // Create roles and assign permissions

        // 1. Customer Role - Can buy tickets
        $customerRole = Role::create(['name' => 'customer']);
        $customerRole->givePermissionTo([
            'buy tickets',
            'view own tickets',
            'view own orders',
            'view events',
        ]);

        // 2. Agent Role - Can scan tickets and process payments
        $agentRole = Role::create(['name' => 'agent']);
        $agentRole->givePermissionTo([
            'scan tickets',
            'verify tickets',
            'check-in tickets',
            'initiate stk push',
            'process payments',
            'view events',
            'view own orders',
        ]);

        // 3. Admin Role - Can manage events and agents
        $adminRole = Role::create(['name' => 'admin']);
        $adminRole->givePermissionTo([
            'view events',
            'create events',
            'edit events',
            'delete events',
            'manage ticket categories',
            'view agents',
            'create agents',
            'edit agents',
            'delete agents',
            'assign agents to events',
            'view users',
            'view all orders',
            'manage orders',
            'view reports',
            'export data',
        ]);

        // 4. Super Admin Role - Full system control
        $superAdminRole = Role::create(['name' => 'super_admin']);
        $superAdminRole->givePermissionTo(Permission::all());

        // Create default users for each role
        
        // Super Admin
        $superAdmin = User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@matiko.com',
            'phone' => '+254712345678',
            'password' => Hash::make('password'),
            'role' => 'super_admin',
            'status' => 'active',
            'email_verified_at' => now(),
        ]);
        $superAdmin->assignRole('super_admin');

        // Admin
        $admin = User::create([
            'name' => 'Admin User',
            'email' => 'admin@matiko.com',
            'phone' => '+254712345679',
            'password' => Hash::make('password'),
            'role' => 'admin',
            'status' => 'active',
            'email_verified_at' => now(),
        ]);
        $admin->assignRole('admin');

        // Agent
        $agent = User::create([
            'name' => 'Agent User',
            'email' => 'agent@matiko.com',
            'phone' => '+254712345680',
            'password' => Hash::make('password'),
            'role' => 'agent',
            'status' => 'active',
            'email_verified_at' => now(),
        ]);
        $agent->assignRole('agent');

        // Customer
        $customer = User::create([
            'name' => 'Customer User',
            'email' => 'customer@matiko.com',
            'phone' => '+254712345681',
            'password' => Hash::make('password'),
            'role' => 'customer',
            'status' => 'active',
            'email_verified_at' => now(),
        ]);
        $customer->assignRole('customer');

        $this->command->info('Roles and permissions created successfully!');
        $this->command->info('Login credentials:');
        $this->command->info('Super Admin: superadmin@matiko.com / password');
        $this->command->info('Admin: admin@matiko.com / password');
        $this->command->info('Agent: agent@matiko.com / password');
        $this->command->info('Customer: customer@matiko.com / password');
    }
}
